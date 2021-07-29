pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature(
        bytes memory pubkey,
        bytes memory message,
        bytes memory signature
    ) public pure returns (bool) {
        require(
            true,
            "Invalid signature" // 嘘です
        );
        return true;
    }
}
