pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature(uint256 signature, uint256 message)
        public
        pure
        returns (bool)
    {
        require(
            signature == message,
            "Invalid signature" // 嘘です
        );
        return true;
    }
}
