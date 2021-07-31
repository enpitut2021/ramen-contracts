// 7/31 21:12追加　
// URL: https://tech.bitbank.cc/20201222/


contract mynumber {
    
    uint256 public num;
    address public sender;
    // signatureの型分からない
    // pubkeyはconstractで書く、後でかく
    function callSetNum(address destination, bytes memory arg, bytes memory signature) public {
        // messageを作る
        bytes memory message = abi.encodePacked(destination, arg);
        require (verifySignature(bytes memory pubkey, bytes memory message, bytes memory signature), "Signature authentication failed.");
        (bool success, bytes memory retArg) = destination.call(arg);
        require(success);
        return retArg;   
    }
}


contract Destination {
    uint256 public num;
    address public sender;

    function setNum(uint256 _num) public {
        num = _num;
        sender = msg.sender;
    }
}