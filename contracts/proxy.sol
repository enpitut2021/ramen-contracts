pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature(bytes memory signature, bytes memory message)
        public
        pure
        returns (bool)
    {
        require(
            signature.length == message.length,
            "Signature and message must be the same length" // 嘘です
        );
        return true;
    }
}
