/**
 * Created on 2020-09-09 16:39
 * @summary: 
 * @author: tron
 */
pragma solidity >0.4.24;
import "ICon.sol";
import "con1.sol";

import "ITRC20.sol";
import "SafeMath.sol";
import "TransferHelper.sol";

/**
 * @title: 
 */
contract Main{
  using SafeMath for uint256;
  using TransferHelper for address;

    uint256 public totalStaked;  //for the number of tokenA all users staked
    ITRC20 public tokenA;
    ITRC20 public tokenB;
    ICon[] public array;
    uint256 public size;
    uint256 public currentPeriod;
    uint256[] public global_timestamp_list;
    uint256[] public global_reward_list;
    uint256 public beginTime;
    uint256 public endTime;
    
    bool public inited;
    uint256[] public everyPeriodTotalStake; // for total share of everyPeriod
    
    mapping(address => uint256) public balance; //the number of tokenA user staked 
    mapping(address => uint256) public reward;  //the number of tokenB user harvest

    mapping(uint256 => address) public cons;
    mapping(address => uint256) public lastHarvest;  //user address : lastHarvest period

    constructor(address tokenA_addr, address tokenB_addr) public{
      size = 0;
      currentPeriod = 0;
      tokenA = ITRC20(tokenA_addr);
      tokenB = ITRC20(tokenB_addr);
    }
    
    modifier checkInited() {
      require(inited == false, "the contract can be inited only one time.");
      _;
    }
    
    modifier checkBegin(){
      require(block.timestamp >= beginTime, "not begin");
      _;
    }
    
    modifier checkEnd(){
      require(block.timestamp <= endTime, "already end");
      _;
    }
    
    /**
     * @dev: 
     * @param memory
     * @param uint256[]
     * @param reward
     */
    function Initialize(uint256[] memory timestamp, uint256[] memory reward) checkInited public{
      require(timestamp.length == reward.length + 1, "timestamp size always one more than reward size.");
      inited = true;
      global_timestamp_list = timestamp;
      global_reward_list = reward;
      while(size < timestamp.length - 1){
        addOnePeriod(timestamp[size], timestamp[size+1], size, reward[size]);
        size++;
      }
      beginTime = global_timestamp_list[0];
      endTime = global_timestamp_list[global_timestamp_list.length-1];
    }
    
    /**
     * @dev: 
     * @param start
     * @param end
     * @param period
     * @param reward
     */
    function addOnePeriod(uint256 start, uint256 end, uint256 period, uint256 reward) public{
     require(start < end, "begin time must lt end time.");
     require(period == size, "period is wrong");
     OnePeriod ins = new OnePeriod(start, end, period, reward);
     array.push(ins);
     ins.setToken(address(tokenA));
   }

   /**
    * @dev: 
    * @param index
    */
   function globalAdvance(uint256 index) public{
    while(currentPeriod != index){
        everyPeriodTotalStake.push(totalStaked);  // everyPeriodTotalStake update
        currentPeriod = currentPeriod.add(1);  // currentPeriod update
      }
    }
    
    /*deposit and withdrawal*/
    /**
     * @dev: 
     * @param amount
     */
    function deposit(uint256 amount) public checkBegin checkEnd returns (bool){
      uint256 index = calcWhichPeriod();
      require(index < size, "not exsits period.");

      globalAdvance(index);
      // harvest before deposit
      harvest(false);

      ICon(array[index]).deposit(msg.sender, address(this), amount);
      require(address(tokenA).safeTransferFrom(msg.sender, address(this), amount), "deposit fail");
      
      balance[msg.sender] = balance[msg.sender].add(amount);
      totalStaked = totalStaked.add(amount);

      return true;
    }
    
    /**
     * @dev: 
     * @param amount
     */
    function withdrawal(uint256 amount) public checkBegin returns(bool){
      uint256 index = calcWhichPeriod();
      require(index < size, "not exsits period");

      globalAdvance(index);
      //harvest before withdrawal
      harvest(false);
      
      ICon(array[index]).withdrawal(msg.sender, amount); //record the withdrawal in period contract
      require(address(tokenA).safeTransfer(msg.sender, amount), "withdrawal fail"); //execute withdrawal tokenA from Main to user
      
      balance[msg.sender] = balance[msg.sender].sub(amount);
      totalStaked = totalStaked.sub(amount);
      return true;
    }
    
    /**
     * @dev: 
     * @param index
     */
    function getUserStakeInPeriod(uint256 index) public view returns (uint256){
      uint256 res = ICon(array[index]).getStakeInPeriod(msg.sender);
      return res;
    }
    
    /**
     * @dev: 
     * @param real
     */
    function harvest(bool real) public {
      uint256 index = calcWhichPeriod();
      uint256 userStake = getUserStakeInPeriod(lastHarvest[msg.sender]); 

      while(index > lastHarvest[msg.sender]){
        uint256 period = lastHarvest[msg.sender];
        uint256 newProfit = 1;
        //uint256 newProfit = global_reward_list[period].mul(userStake).div(everyPeriodTotalStake[period]);
        reward[msg.sender] = reward[msg.sender].add(newProfit);
        lastHarvest[msg.sender] = period.add(1);
      }
      if(real){
        realharvest(); //execute send tokenB
      }

    }
    
    /**
     * @dev: 
     */
    function realharvest() public{
      require(address(tokenB).safeTransfer(msg.sender, reward[msg.sender]), "realharvest fail");
      reward[msg.sender] = 0;
    }

    
    /**
     * @dev: 
     */
    function calcWhichPeriod() public view returns (uint256){
      uint256 i = 0;
      while(i < size){
        if(block.timestamp > global_timestamp_list[i]){
          i = i.add(1);
          }else{
            break;
          }
        }
        return i.sub(1);
      }

      /**
       * @dev: 
       * @param index
       */
      function getTokenByIndex(uint256 index) public view returns(address){
        return array[index].getToken();
      }

    }