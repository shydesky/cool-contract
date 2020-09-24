pragma solidity ^0.5.8;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeTRC20.sol";
import "./Math.sol";

contract IRewardDistributionRecipient is Ownable {
    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {
        rewardDistribution = _rewardDistribution;
    }
}


contract LPTokenWrapper {
    using SafeMath for uint256;
    using SafeTRC20 for ITRC20;

    ITRC20 public tokenAddr;  //SUN/TRX的LP token
    uint256 private _totalSupply;  // 记录挖矿合约所拥有的LP token。
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    // 流动性从用户转移给挖矿合约
    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        tokenAddr.safeTransferFrom(msg.sender, address(this), amount);
    }

    // 流动性从挖矿合约转移给用户
    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        tokenAddr.safeTransfer(msg.sender, amount);
    }
}

contract SunSUNTRXPool is LPTokenWrapper, IRewardDistributionRecipient {
    // sunToken
    ITRC20 public sunToken = ITRC20(0x6b5151320359Ec18b08607c70a3b7439Af626aa3);
    uint256 public constant DURATION = 1_209_600; // 14 days

    uint256 public starttime = 1600268400; // 2020/9/16 23:0:0 (UTC UTC +08:00)
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;  //每秒的奖励速度。
    uint256 public lastUpdateTime;  //上次的更新时间，最近一次用户。
    uint256 public rewardPerTokenStored;  //全局的 每个LP token获取的奖励数量。
    mapping(address => uint256) public userRewardPerTokenPaid;  //每个用户已经结算的奖励。
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event Rescue(address indexed dst, uint sad);
    event RescueToken(address indexed dst,address indexed token, uint sad);

    constructor(address _trc20, uint256 _starttime) public{
        tokenAddr = ITRC20(_trc20);
        rewardDistribution = _msgSender();
        starttime = _starttime;
    }


    modifier checkStart() {
        require(block.timestamp >= starttime,"not start");
        _;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;  //记录上次已经
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)   //当前的区块时间 - 上次的区块时间
                    .mul(rewardRate)       //乘以奖励速率
                    .mul(1e18)             
                    .div(totalSupply())    //总的LP数量
            );
    }


    //记录用户已经赚取的奖励
    function earned(address account) public view returns (uint256) {
        return
            balanceOf(account) //用户LP的数量 
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account])) //这段时间每个LP token应该获取的奖励。
                .div(1e18)
                .add(rewards[account]); //用户奖励原值
    }

    // stake LP， stake之前通过modifer方法 updateReward 结算一下用户的收益。
    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    // unstake LP， unstake之前通过modifier方法 updateReward 结算一下用户的收益
    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function withdrawAndGetReward(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount <= balanceOf(msg.sender), "Cannot withdraw exceed the balance");
        withdraw(amount);
        getReward();
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        uint256 trueReward = earned(msg.sender);
        if (trueReward > 0) {
            rewards[msg.sender] = 0;
            sunToken.safeTransfer(msg.sender, trueReward);
            emit RewardPaid(msg.sender, trueReward);
        }
    }


    // 挖矿开始前进行此方法调用，计算rewardRate = 49000 * 10**18 * 14 / 1209600
    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {
        if (block.timestamp > starttime) {
          if (block.timestamp >= periodFinish) {
              rewardRate = reward.div(DURATION);
          } else {
              uint256 remaining = periodFinish.sub(block.timestamp);
              uint256 leftover = remaining.mul(rewardRate);
              rewardRate = reward.add(leftover).div(DURATION);
          }
          lastUpdateTime = block.timestamp;
          periodFinish = block.timestamp.add(DURATION);
          emit RewardAdded(reward);
        } else {
          rewardRate = reward.div(DURATION);
          lastUpdateTime = starttime;
          periodFinish = starttime.add(DURATION);
          emit RewardAdded(reward);
        }
    }
    /**
    * @dev rescue simple transfered TRX.
    */
    function rescue(address payable to_, uint256 amount_)
    external
    onlyOwner
    {
        require(to_ != address(0), "must not 0");
        require(amount_ > 0, "must gt 0");

        to_.transfer(amount_);
        emit Rescue(to_, amount_);
    }
    /**
     * @dev rescue simple transfered unrelated token.
     */
    function rescue(address to_, ITRC20 token_, uint256 amount_)
    external
    onlyOwner
    {
        require(to_ != address(0), "must not 0");
        require(amount_ > 0, "must gt 0");
        require(token_ != sunToken, "must not sunToken");
        require(token_ != tokenAddr, "must not this plToken");

        token_.transfer(to_, amount_);
        emit RescueToken(to_, address(token_), amount_);
    }
}
