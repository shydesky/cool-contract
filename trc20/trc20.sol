pragma solidity >=0.5.0;

import './SafeMath.sol';
import './TRC20Interface.sol';

contract TRC20Token is ITRC20{

  using SafeMath for uint256;

  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  
  constructor(address owner, uint256 initialSupply, string memory name, string memory symbol, uint8 decimals) public {
    _totalSupply = initialSupply;
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _balances[owner] = initialSupply;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }

  function name() external view returns (string memory) {
    return _name;
  }

  function decimals() external view returns (uint8) {
    return _decimals;
  }

  function symbol() external view returns (string memory) {
    return _symbol;
  }

  function balanceOf(address owner) public view returns (uint256 balance){
    return _balances[owner];
  }

  function transfer(address to, uint256 value) public returns (bool success){
    require (value <= _balances[msg.sender], "sender does not have enough token.");
    require (to != address(0));
    
    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function approve(address spender, uint256 value) public returns (bool success){
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }


  function transferFrom(address from, address to, uint256 value) public returns (bool success){
    require (value <= _balances[from]);
    require (value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, value);
    return true;
  }

  function allowance(address owner, address spender) public view returns (uint256){
    return _allowed[owner][spender];
  }

}
