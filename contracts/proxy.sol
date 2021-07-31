pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    //認証部分　rfc8017 8.2.2 参照
    //https://datatracker.ietf.org/doc/html/rfc8017#page-35
    function verifySignature{
        bytes memory pubkey,
        bytes memory message,
        bytes memory signature;
                                                        // 公開鍵を分解する n,e (省略)
                                                        
                                                        //s = OS2IP(バイト列を数値に変換する場所) (8.2.2の2のa,省略)
        
        // RSAVP1の適用を書く場所 solidityではEIP198で計算。
        // define callBigModExp
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        /////       "EIP-198"                                                                           ////
        /////       function callBigModExp(s,e,n) return (s^e mod n)                                    ////
        /////                                                                                           ////
        /////           memcpy(),join() are used by callBigModExp()                                     ////
        /////                                                                                           ////
        /////       "reference"                                                                         ////
        /////        https://github.com/adria0/SolRsaVerify/blob/master/contracts/SolRsaVerify.sol      ////
        /////        https://solidity-jp.readthedocs.io/ja/latest/assembly.html                         ////
        /////        https://ethervm.io/                                                                ////
        //////////////////////////////////////////////////////////////////////////////////////////////////// 

        function memcpy(uint _dest, uint _src, uint _len) pure internal {
            // Copy word-length chunks while possible
            for ( ;_len >= 32; _len -= 32) {
                assembly {
                    mstore(_dest, mload(_src))
                }
                _dest += 32;
                _src += 32;
            }
            // Copy remaining bytes
            uint mask = 256 ** (32 - _len) - 1;
            assembly {
                let srcpart := and(mload(_src), not(mask))
                let destpart := and(mload(_dest), mask)
                mstore(_dest, or(destpart, srcpart))
            }
        }   
        function join(bytes memory _s, bytes memory _e, bytes memory _m) pure internal returns (bytes memory) {
            uint inputLen = 0x60+_s.length+_e.length+_m.length;
            uint slen = _s.length;
            uint elen = _e.length;
            uint mlen = _m.length;
            uint sptr;
            uint eptr;
            uint mptr;
            uint inputPtr;
            bytes memory input = new bytes(inputLen);
            assembly {
                sptr := add(_s,0x20)
                eptr := add(_e,0x20)
                mptr := add(_m,0x20)
                mstore(add(input,0x20),slen)
                mstore(add(input,0x40),elen)
                mstore(add(input,0x60),mlen)
                inputPtr := add(input,0x20)
            }
            memcpy(inputPtr+0x60,sptr,_s.length);        
            memcpy(inputPtr+0x60+_s.length,eptr,_e.length);        
            memcpy(inputPtr+0x60+_s.length+_e.length,mptr,_m.length);
            return input;
        }
        function callBigModExp(bytes memory base, bytes memory exponent, bytes memory modulus) public returns (bytes memory result) {
                bytes memory input = join(base,exponent,modulus);
                uint inputlen = input.length;
                uint decipherlen = modulus.length;
                bytes memory decipher = new bytes(decipherlen);
                assembly {
                    let success := staticcall(gas, 5, add(input,0x20), inputlen, add(decipher,0x20), decipherlen)
                    switch success
                    case 0 {
                        revert(0x0, 0x0)
                    } default {
                        result := decipher
                    }
                }
        }
        ////////////////////////////////////////////////////////////////////////////////////////////////////
        /////     8.2.2 の 2 の b                                                                        ////
        /////                                                                                           ////
        /////                                                                                           ////
        /////                                                                                           ////
        ////////////////////////////////////////////////////////////////////////////////////////////////////

        // bに対応
        // -------------------------------------------
        // makeMの署名代表が範囲外の所を画面に出力できるようにしたい
        // メッセージをmに代入したい
        // 変数の入れ方とか細かいところわからないからお願いします。
        // -------------------------------------------
        uint m;
        
        function makeM(bytes _s, bytes _e, bytes _n) pure public returns(bytes){
            if(s>n-1){
                return "署名代表が範囲外です";
            }
            //return s ** e % n;
            return 
        }
        m = makeM(s,e,n);
                            // mをエンコードしたメッセージ(バイト列かな)に変換する場所(省略)

        // EMSA-PSSじゃなくて、RSASSA-AKCS1-v-5で検証
        // 型を適当に書いてるから、型の確認をお願いします。
        // 型の確認をお願いします。適当にやっちゃってる
        function checkByRSSA(uint256 _m, uint256 emLen) pure public returns(uint256){
        uint h;
        // # 1(9.2)
        // define hash URL: https://daiki-sekiguchi.com/2018/07/23/ethereum-solidity-keccak256/
        function getHash(string _str) pure returns (bytes32) {
            return keccak256(_str);
        }
        // H = hash(m)
        h = getHash(m);
        // if len(h) >>: print("メッセージが長過ぎます")
        // ハッシュが長いと勝手にmessage too longって出るっぽいけど、もしかしたら俺らで定義する必要あるかも、
        // if()


        // # 2(9.2) 参考資料：https://qiita.com/kunichiko/items/2e0a2bd35c8e9492ceb5
        // Digestinfo new_h = DER(str(Digestinfo)+str(H))
        uint256 T;
        uint256 tLen;
        // # 3(9.2)
        // if emLen < tLen+11 -> print(意図されたエンコードされたメッセージの長さが短過ぎます)
        // 画面の出力の仕方が分かりません。直してくれ〜
        if(emLen < tLen+11){
            return "intended encoded message length too short";
        }
        // # 4(9.2)
        // PS = emLen-tLen-3
        uint256 PS;
        PS = emLen-tLen-3
        // # 5(9.2)
        // EM = 0x00 || 0x01 || PS || 0x00 || T.
        // ||が何を表してるか分からないわ。文字列の結合とかでいいなら、足し算すればいいんだけど
        EM = 0x00 || 0x01 || PS || 0x00 || T;
        
            return EM;
        }
    // # 6(9.2)
    // Resultによって出力
    // Result = "consistent"の場合、 "validsignature"を出力する。
    // それ以外の場合は、「無効な署名」を出力する。
    uint256 Result;
    Result = EM;
    if(Result == EM'){
        return "valid signature";
    }
    else{
        return "invalid signature";
    }
    
}


    ) public pure returns (bool) {
        require(
            true,
            "Invalid signature" // 嘘です
        );
        return true;
    }
}

