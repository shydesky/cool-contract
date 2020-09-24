pragma solidity ^0.4.24;

//logi命令接收i+1个bytes32参数。
//log0～log4将第一个参数做为数据data，其他作为topic，log0是没有topic的。
//event会将indexed修饰的字段作为topic，其他作为数据data。
//如果event不是anonymous的，还会将event的签名也作为topic，放到第1个。
//event最多支持4个indexed的参数，因此如果event不是anonymous的，那么还有3个参数可以设置为indexed。
//event的参数如果是数组（包括String和bytes），并且被标记为indexed，那么会用对应的Keccak-256哈希值作为topic。
//如果没有被标记为indexed，放到data里面就不会用hash了。
contract LOG{
    event LOG0();
    event LOG1(uint256);
    event LOG2(uint256 indexed);
    event LOG3(uint256 indexed, string indexed);
    event LOG4(uint256 indexed, string, string indexed);
    event NewLog(string indexed, string indexed, string indexed, string indexed) anonymous;

    function printAlog0() public{
        bytes32 a = bytes32("A");
        log0(a);
        emit LOG0();
    }
    
    function printAlog1() public{
        bytes32 a = bytes32("A");
        log1(bytes32(msg.sender), a);
        emit LOG1(100);
    }
    
    function printAlog2() public{
        bytes32 a = bytes32("A");
        bytes32 b = bytes32("B");
        log2(bytes32(msg.sender), a, b);
        emit LOG2(100);
    }
    
    function printAlog3() public{
        string memory abc = "hello,world";
        bytes32 a = bytes32("A");
        bytes32 b = bytes32("B");
        bytes32 c = bytes32("C");

        log3(bytes32(msg.sender), a, b, c);
        emit LOG3(100, "ABC");
    }
    
    function  printAlog4() public{
        bytes32 a = bytes32("A");
        bytes32 b = bytes32("B");
        bytes32 c = bytes32("C");
        bytes32 d = bytes32("D");

        log4(bytes32(msg.sender), a, b, c, d);
        emit LOG4(100, "ABC", "DEF");
    }

    function  printNewLog() public{
        //因为NewLog是anonymous的，所以这四个参数最终都会成为topic
        emit NewLog("ABC", "DEF", "abc", "def");  
    }
    
}