pragma solidity >0.4.24;

interface ICon{
    
    event Deposit(address indexed addr, uint256 indexed period, uint256 amount);
    event Withdrawal(address indexed addr, uint256 indexed period, uint256 amount);
    
    function deposit(address, address, uint256) external returns (bool);
    function withdrawal(address, uint256) external returns (bool);
    function getStakeInPeriod(address) external view returns (uint256);
    
    function setToken(address) external returns (bool);
    function getToken() external view returns (address);
    function getStarttime() view external returns(uint256);
}