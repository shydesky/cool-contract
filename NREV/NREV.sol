pragma solidity ^0.4.16;

import "./strings.sol";
import "./cylib.sol";
import "./datetime.sol";
import "./cymath.sol";

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract NREV is dateTime, cylib {
    using cymath for uint;
    using strings for *;
  
    address minter;
    string public name;
    string public symbol;
    uint256 public decimals;
    
    uint256 _totalSupply;
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    uint256 burnTotal;
    uint256 jackpot;
    uint uid;
    uint rewardNum;
    
    mapping (address => uint256) accountAddrToIdMap;
    mapping (uint256 => address) accountIdToAddrMap;
    mapping (address => uint256) balanceOfMap;
    mapping (address => mapping (address => uint256)) public allowance;
    
    uint startOfferPrice = 2000;
    uint originStartOfferPrice;
    uint offerPriceStep = 200;
    uint offerPriceMax = 20000;
    
    mapping (uint256 => mapping (address => uint256)) gtOfferPriceMap; //jackpot people join count
    mapping (uint256 => address[]) offerPriceAddressMap;

    uint dividendEach = 50000;
    uint dividendPercent = 33; //33%
    address dividendAddress;
    address rewardAddress;
    address contractAddress;
    
    mapping (uint256 => mapping (address => uint256)) addrToShareMap;
    mapping (uint256 => address[]) shareAddress;
    mapping(uint256 => mapping(address => uint256)) transferRecords;

    uint public pieAwardEndTime;

    constructor() public {
        name = 'NREV token';
        symbol = "NREV";
        decimals = 18;
    
        _totalSupply = 100000000 * 10 ** decimals;
        balanceOfMap[msg.sender] = _totalSupply;
        minter = msg.sender;
        
        rewardAddress = address(0xc0B54C3EcD31e921a8d04f2C8BcE4f21ACCe7d79);
        dividendAddress = address(0x26d3F7A8e8A25aB8E97c03DDEFEc3a20c3aaf0dE);
        contractAddress = address(this);
        balanceOfMap[contractAddress] = _totalSupply;
        
        startOfferPrice = startOfferPrice * 10 ** decimals;
        originStartOfferPrice = startOfferPrice;
        offerPriceStep = offerPriceStep * 10 ** decimals;
        dividendEach = dividendEach * 10 ** decimals; 
        offerPriceMax = offerPriceMax * 10 ** decimals;
        
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    
    function getJackpotAddress() public view returns(string){
        require(msg.sender == minter);
        
        string memory _tmp;
        
        uint len = offerPriceAddressMap[rewardNum].length;
        
        if(len > 0){
            for(uint i = 0; i < len; i++){
                address _tmpAddr = offerPriceAddressMap[rewardNum][i];
                uint offerPrice = gtOfferPriceMap[rewardNum][_tmpAddr];
                _tmp = _tmp.toSlice().concat(hhToString(_tmpAddr).toSlice());
                _tmp = _tmp.toSlice().concat("_".toSlice());
                _tmp = _tmp.toSlice().concat(cyToString(offerPrice).toSlice());
                _tmp = _tmp.toSlice().concat(",".toSlice());
            }            
        }
        return (_tmp);
    }    
    
    function getAddr() public view returns(address){
        return address(this);
    }
    
    function preEachShareToken() internal view returns(uint){
        uint totalShare;
        uint _nowDate = today();
        
        for(uint i = 1; i <= uid; i++){
            uint _balance = balanceOfMap[accountIdToAddrMap[i]];
            if(_balance < dividendEach) continue;
            
            //check is yesterday has the transfer record
            if(transferRecords[_nowDate][accountIdToAddrMap[i]] > 0) continue;
            
            totalShare += uint(_balance)/uint(dividendEach);
        }
        
        if(totalShare < 1) return 0;
        
        uint dividendToken = balanceOfMap[dividendAddress].mul(dividendPercent).div(100);
        uint eachShareToken = uint(dividendToken)/uint(totalShare);
        
        return eachShareToken;
    }
    
    function preDividendUser() internal view returns(uint){
        uint _nowDate = today();
        uint total;
        
        for(uint i = 1; i <= uid; i++){
            uint _balance = balanceOfMap[accountIdToAddrMap[i]];
            if(_balance < dividendEach) continue;
            
            //check is yesterday has the transfer record
            if(transferRecords[_nowDate][accountIdToAddrMap[i]] > 0) continue;
            
            total++;
        }
        return total;
    }
    
    function dividendMoney() public returns(uint){
        require(msg.sender == dividendAddress);
        
        uint totalShare;
        uint _nowDate = yesterday();
        
        for(uint i = 1; i <= uid; i++){
            if(accountIdToAddrMap[i] == minter) continue;
            
            uint _balance = balanceOfMap[accountIdToAddrMap[i]];
            if(_balance < dividendEach) continue;
            
            //check is yesterday has the transfer record
            if(transferRecords[_nowDate][accountIdToAddrMap[i]] > 0) continue;
            
            uint _share = uint(_balance)/uint(dividendEach);
            
            shareAddress[_nowDate].push(accountIdToAddrMap[i]);
            addrToShareMap[_nowDate][accountIdToAddrMap[i]] = _share;
            
            totalShare += _share;
        }
        
        if(totalShare < 1) return 0;
        if(shareAddress[_nowDate].length < 1) return 0;
        
        uint dividendToken = balanceOfMap[msg.sender].mul(dividendPercent).div(100);
        uint eachShareToken = uint(dividendToken)/uint(totalShare);
        
        for(uint j = 0; j < shareAddress[_nowDate].length; j++){
            uint amount = eachShareToken.mul(addrToShareMap[_nowDate][shareAddress[_nowDate][j]]);
            _transferWithNoJackpot(msg.sender, shareAddress[_nowDate][j], amount);
        }
        return shareAddress[_nowDate].length;
    }
    
    function webShow() public view returns(
        uint256 _curBalance,
        uint256 _burnRate,
        uint256 _burnTotal,
        uint256 _jackpot,
        uint totalUser,
        uint _hourPot,
        uint _minOfferPrice,
        uint _rewardNum,
        uint _preDividendUser,
        uint _preEachShareToken,
        uint _pieAwardEndTime
    ){
        uint hourPot = balanceOfMap[rewardAddress];
        uint minOfferPrice = startOfferPrice;
        
        if(minOfferPrice < 1){
            minOfferPrice = startOfferPrice;
        }
        
        return (
            balanceOfMap[contractAddress], 
            getBurnRate(), 
            burnTotal,
            jackpot,
            uid,
            hourPot,
            minOfferPrice,
            rewardNum,
            preDividendUser(),
            preEachShareToken(),
            getPieAwardEndTime()
        );
    }

    function getPieAwardEndTime() public view returns(uint _pieAwardEndTime){
        return pieAwardEndTime;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        register(_from);
        register(_to);
        
        require(_to != 0x0);
        require(balanceOfMap[_from] >= _value, "not much token");
        
        uint originValue = _value;
        uint burnRate = getBurnRate();
        uint burnCoin = _value.mul(burnRate).div(100);
        _value = _value.sub(burnCoin);
        burnTotal = burnTotal.add(burnCoin);
        
        balanceOfMap[contractAddress] = balanceOfMap[contractAddress].sub(burnTotal);
        
        //jackpot
        jackpot = jackpot.add(burnCoin);
        _value = _value.sub(burnCoin);
        setJackpotMap(_from, burnCoin);
        
        _setJackpot(_from, originValue);
        
        require(balanceOfMap[_to].add(_value) >= balanceOfMap[_to]);
        
        balanceOfMap[_from] = balanceOfMap[_from].sub(originValue);
        balanceOfMap[_to] = balanceOfMap[_to].add(_value);
        
        _addTransferRecord(_from, originValue);
        
        emit Transfer(_from, _to, _value);
    }
    
    function _addTransferRecord(address _from, uint amount) internal {
        transferRecords[today()][_from] = amount;
    }
    
    function _transferWithNoJackpot(address _from, address _to, uint _value) internal {
        register(_from);
        register(_to);
        
        require(_to != 0x0);
        
        require(balanceOfMap[_from] >= _value);
        require(balanceOfMap[_to].add(_value) >= balanceOfMap[_to]);
        
        balanceOfMap[_from] = balanceOfMap[_from].sub(_value);
        balanceOfMap[_to] = balanceOfMap[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }
    
    function _setJackpot(address fromAddr, uint amount) internal {
        if((fromAddr == minter) || (amount < startOfferPrice)) return;
  
        startOfferPrice = startOfferPrice.add(offerPriceStep);
        if(startOfferPrice >= offerPriceMax){
            startOfferPrice = offerPriceMax;
        }
        
        gtOfferPriceMap[rewardNum][fromAddr] = amount;
        offerPriceAddressMap[rewardNum].push(fromAddr);
        
        //reset next  pie award time
        pieAwardEndTime = time() + 3600;
    }
    
    function pieAward(address _to, uint level) public returns(bool){
        require(rewardAddress == msg.sender, "pie award wrong require address");
        require(pieAwardEndTime > 0 && time() > pieAwardEndTime, "pie award time is 0");
        
        uint reward;
        
        //to top 1
        if(level == 1){
            reward = balanceOfMap[msg.sender].mul(15).div(100);
        }
        
        //to top 2-10
        if(level == 2){
            reward = balanceOfMap[msg.sender].mul(2).div(100);
        }
        
        //to team
        if(level == 3){
            reward = balanceOfMap[msg.sender].mul(5).div(100);
        }
   
        //to dividend
        if(level == 4){
            reward = balanceOfMap[msg.sender];
            _transferWithNoJackpot(msg.sender, dividendAddress, reward);
            rewardNum++;
            pieAwardEndTime = 0;
            startOfferPrice = originStartOfferPrice;
        }else{
            _transferWithNoJackpot(msg.sender, _to, reward);
        }
        return true;
    }
    
    function setJackpotMap(address fromAddr, uint amount) internal {
        if(fromAddr != minter) {
            balanceOfMap[rewardAddress] = balanceOfMap[rewardAddress].add(amount);
        }
    }

    function transfer(address _to, uint256 _value) public {
        _value = _getOriginValue(_value);
        _transfer(msg.sender, _to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        _value = _getOriginValue(_value);
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _value = _getOriginValue(_value);
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        _value = _getOriginValue(_value);
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
    
    function _getOriginValue(uint _value) internal constant returns(uint){
        uint _originTotalSupply = _totalSupply.div(10 ** decimals);
        if(_value < _originTotalSupply){
            _value = _value * 10 ** decimals;
        }
        return _value;
    }
    
    function totalSupply() public constant returns (uint theTotalSupply){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public constant returns (uint balance){
        return balanceOfMap[_owner];
    }
    
    function allowance(address _owner, address _spender) public constant returns (uint remaining){
        return allowance[_owner][_spender];
    }
    
    function register(address _address) internal {
        if(accountAddrToIdMap[_address] < 1){
            uid++;
            accountAddrToIdMap[_address] = uid;
            accountIdToAddrMap[uid] = _address;
        }
    }
    
    function getNowHour() internal constant returns(uint){
        uint nowTemp = time();
        uint _year = getYear(nowTemp);
        uint _month = getMonth(nowTemp);
        uint _day = getDay(nowTemp);
        uint _hour = getHour(nowTemp);
        
        string memory strTmp;
        
        strTmp = strTmp.toSlice().concat(cyToString(_year).toSlice());
        
        if(_month < 10){
            strTmp = strTmp.toSlice().concat("0".toSlice());
        }
        strTmp = strTmp.toSlice().concat(cyToString(_month).toSlice());
        
        if(_day < 10){
            strTmp = strTmp.toSlice().concat("0".toSlice());
        }
        strTmp = strTmp.toSlice().concat(cyToString(_day).toSlice());
        
        if(_hour < 10){
            strTmp = strTmp.toSlice().concat("0".toSlice());
        }
        strTmp = strTmp.toSlice().concat(cyToString(_hour).toSlice());
        
        return stringToUint(strTmp);
    }
    
    function _getDate(uint _type) internal constant returns(uint){
        uint nowTemp = time();
        
        if(_type == 2){
            nowTemp -= 86400;
        }
        
        uint _year = getYear(nowTemp);
        uint _month = getMonth(nowTemp);
        uint _day = getDay(nowTemp);
        
        string memory strTmp;
        
        strTmp = strTmp.toSlice().concat(cyToString(_year).toSlice());
        
        if(_month < 10){
            strTmp = strTmp.toSlice().concat("0".toSlice());
        }
        strTmp = strTmp.toSlice().concat(cyToString(_month).toSlice());
        
        if(_day < 10){
            strTmp = strTmp.toSlice().concat("0".toSlice());
        }
        strTmp = strTmp.toSlice().concat(cyToString(_day).toSlice());
        return stringToUint(strTmp);
    }
    
    function yesterday() internal constant returns(uint){
        return _getDate(2);
    }
    
    function today() internal constant returns(uint){
        return _getDate(1);
    }    
    
    //get the burn rate
    function getBurnRate() public view returns(uint){
        uint amount = balanceOfMap[contractAddress];
        
        if(amount >= 100000000 * 10 ** decimals){
            return 6;
        }
        
        // 8 ~ 10
        if(amount >= 80000000 * 10 ** decimals){
            return 5;
        }
        
        // 6 ~ 8
        if(amount >= 60000000 * 10 ** decimals){
            return 4;
        }
        
        // 4 ~ 6
        if(amount >= 40000000 * 10 ** decimals){
            return 3;
        }
        
        // 2 ~ 4
        if(amount >= 20000000 * 10 ** decimals){
            return 2;
        }
        
        // 0~2
        return 1;
    }
}