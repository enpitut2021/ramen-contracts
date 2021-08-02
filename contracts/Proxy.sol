pragma solidity ^0.8.0;
import "./Verifier.sol";

contract Proxy {
    bytes public exponent;
    bytes public modulus;
    uint256 public transactionCount;

    constructor(bytes memory _exponent, bytes memory _modulus) {
        exponent = _exponent;
        modulus = _modulus;
        transactionCount = 0;
    }

    function proxy(
        address target, // address of the target contract
        uint256 nonce, // nonce
        bytes memory argument, // the argument(calldata) to send to the target contract
        bytes memory signature // the signature of `abi.encode(target, argument, nonce)`
    ) public returns (bytes memory) {
        // begin requirements check
        require(nonce == transactionCount, "Invalid nonce");
        bytes memory toHash = abi.encode(target, argument, nonce);
        require(
            Verifier.verifySignature(
                modulus,
                exponent,
                sha256(toHash),
                signature
            ),
            "Invalid signature"
        );
        // begin state mutation
        (bool success, bytes memory ret) = target.call(argument);
        require(success, "Target contract execution failed");
        transactionCount++;
        return ret;
    }

    function proxyWithValue(
        address target, // address of the target contract
        uint256 nonce, // nonce
        uint256 value, // the value to send to the target contract
        bytes memory argument, // the argument(calldata) to send to the target contract
        bytes memory signature // the signature of `abi.encode(target, argument, nonce)`
    ) public returns (bytes memory) {
        // begin requirements check
        require(nonce == transactionCount, "Invalid nonce");
        bytes memory toHash = abi.encode(target, argument, value, nonce);
        require(
            Verifier.verifySignature(
                modulus,
                exponent,
                sha256(toHash),
                signature
            ),
            "Invalid signature"
        );
        // begin state mutation
        (bool success, bytes memory ret) = target.call{value: value}(argument);
        require(success, "Target contract execution failed");
        transactionCount++;
        return ret;
    }

    function proxyForEther(
        address payable target, // address of the destination account
        uint256 nonce, // nonce
        uint256 value, // the value to send to destination
        bytes memory signature // the signature of `abi.encode(target, argument, nonce)`
    ) public {
        // begin requirements check
        require(nonce == transactionCount, "Invalid nonce");
        bytes memory toHash = abi.encode(target, value, nonce);
        require(
            Verifier.verifySignature(
                modulus,
                exponent,
                sha256(toHash),
                signature
            ),
            "Invalid signature"
        );
        // begin state mutation
        bool success = target.send(value);
        require(success, "Transfer failed");
        transactionCount++;
    }
}
