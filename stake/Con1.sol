pragma solidity >0.4.24;

import "ICon.sol";
import "ITRC20.sol";
import "SafeMath.sol";
import "TransferHelper.sol";

contract OnePeriod is ICon{
    
    using SafeMath for uint256;
    using TransferHelper for address;

    mapping(address => uint256) internal _balance;
    
    uint256 public starttime;
    uint256 public endtime;
    ITRC20 public token;
    uint256 public period;
    
    
    uint256 public periodTotalStake;
    uint256 public periodTotalReward;

    modifier checkStart() {
        require(block.timestamp > starttime, "not start");
        _;
    }
    
    modifier checkEnd() {
        require(block.timestamp >= endtime, "not end");
        _;
    }
    
    constructor(uint256 start, uint256 end, uint256 _period, uint256 reward) public {
       starttime = start;
       endtime = end;
       period = _period;
       periodTotalReward = reward;
    }
    
    function setToken(address addr) public returns(bool){
        token = ITRC20(addr);
        return true;
    }
    
    function getToken() public view returns(address){
        return address(token);
    }
    
    
    function deposit(address from, address to, uint256 amount) checkStart public returns(bool) {
        //address(token).safeTransferFrom(from, to, amount);
        _balance[from] = _balance[from].add(amount);
        periodTotalStake = periodTotalStake.add(amount);
        emit Deposit(from, period, amount);
        return true;
    }
    
    function withdrawal(address addr, uint256 amount) checkEnd public returns(bool){
        require(amount > 0, "balance must gt 0");
        require(amount <= _balance[addr], "balance not enough");
        _balance[addr] = _balance[addr].sub(amount);
       // address(token).safeTransfer(addr, amount);
        emit Withdrawal(addr, period, amount);
        return true;
    }
    
    function getStakeInPeriod(address addr) public view returns(uint256){
        return _balance[addr];
    }
    
    function getStarttime() public view returns(uint256){
        return starttime;
    }
    
    /**
    * @dev Returns the smallest of two numbers.
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}