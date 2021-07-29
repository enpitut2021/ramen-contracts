pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature(bytes memory signature, bytes memory message)
        public
        pure
        returns (bool)
    {
        return true;
    }
}
