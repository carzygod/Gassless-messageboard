/**
TODO : 
    - Add data array to storage the data into contract ; 
    - New topic .
    - New answer into the topic .
 */

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract messageBoard {
    using SafeMath for uint256;

    /** Msg Struct */
    struct message {
        address owner;
        uint256 tid;
        uint256 mid;
        string data;
        uint256 timestamp;
    }
    /** Topic Struct */
    struct topic {
        address owner;
        uint256[] msgs;
        string data;
        uint256 timestamp;
    }

    topic[] private _topic ;
    message[] private _msg;

    /** Init constuctor */
    constructor() {
        newTopic("Hello world !");
        newMsg(0,0,"The first message of this contract !");
    }

/** 
 * Write-able functions
 */

    function newTopic(string memory data) public 
    {
        topic memory _t ;
        _t.owner = msg.sender;
        _t.data = data;
        _t.timestamp = block.timestamp;
        _topic.push(_t);
    }

//Every new message directly to the topic will point to _msg[0]

    function newMsg(uint256 tId ,uint256 mId,string memory data) public 
    {
        verfiTopic(tId);
        verfiMessage(mId);
        message memory _m ;
        _m.tid = tId;
        _m.mid = mId;
        _m.data = data;
        _m.owner = msg.sender;
        _m.timestamp = block.timestamp;
        _msg.push(_m);
        _topic[tId].msgs.push(_msg.length-1);
    }

    function verfiTopic(uint256 tid) public view returns (bool)
    {
        require(tid<_topic.length,"wrong topic id");
        return true;
    }

    function verfiMessage(uint256 mid) public view returns (bool)
    {
        if(mid!=0)
        {
            require(mid<_msg.length,"wrong message id");
        }
        return true;
    }

/**
 * Read-only functions
 */
    function getMsgById(uint256 mid) public view returns (message memory)
    {
        return _msg[mid];
    }

    function getTopicById(uint256 tid) public view returns (topic memory)
    {
        return _topic[tid];
    }

    function getNonce() public view returns (uint256[2] memory)
    {
        return [_topic.length-1,_msg.length-1];
    }
}