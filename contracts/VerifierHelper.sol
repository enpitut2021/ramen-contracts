import "./Verifier.sol";

contract VerifierHelper {
    function verifySignature(
        bytes memory _modulus, // 256 bytes
        bytes memory _exponent, // 256 bytes
        bytes32 _msgHash, // SHA256 hash of message
        bytes memory _signature // 256 bytes
    ) public view returns (bool) {
        return
            Verifier.verifySignature(_modulus, _exponent, _msgHash, _signature);
    }

    function checkPaddedString(bytes memory encoded, bytes32 msgHash)
        public
        pure
        returns (bool)
    {
        return Verifier.checkPaddedString(encoded, msgHash);
    }

    function bigModExp(
        bytes memory _s, // 256-byte buffer
        bytes memory _e, // 1 <= _e.length <= 256
        bytes memory _m // 256-byte buffer
    ) public view returns (bytes memory result) {
        return Verifier.bigModExp(_s, _e, _m);
    }
}
