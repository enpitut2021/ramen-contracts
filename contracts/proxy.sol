pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature(
        bytes memory pubkey,
        bytes memory message,
        bytes memory signature

        // RSAVP1の適用を書く場所

        // メッセージ代表mをエンコードされたメッセージに変換する場所

        // EMSAーPSS検証を適用するところ

        // Result = "consistent"の場合、 "validsignature"を出力します。
        //   それ以外の場合は、「無効な署名」を出力する。


    ) public pure returns (bool) {
        require(
            true,
            "Invalid signature" // 嘘です
        );
        return true;
    }
}
