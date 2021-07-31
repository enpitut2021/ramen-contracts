pragma solidity ^0.8.6;

contract Proxy {
    constructor() {}

    function verifySignature{
        bytes memory pubkey,
        bytes memory message,
        bytes memory signature;
                        // 公開鍵を分解する n,e (省略)
                        
                        // s = OS2IP(バイト列を数値に変換する場所) (省略)
        
        // RSAVP1の適用を書く場所 solidityではEIP198で計算。
        // define callBigModExp

        // -------------------------------------------
        // 固定長の部分直しておいて欲しいわ 
        // -------------------------------------------

        function callBigModExp(bytes memory base, bytes memory exponent, bytes memory modulus) public returns (bytes memory result) {
            bytes memory input = join(base,exponent,modulus);
            uint inputlen = input.length;//256*3+2048*3
            uint decipherlen = modulus.length;//2048
            bytes memory decipher = new bytes(decipherlen);
            assembly {
                let success := staticcall(gas, 0x05, add(0x300,input), inputlen, decipher, decipherlen)
                switch success
                case 0 {
                    revert(0x0, 0x0)
                } default {
                    result := decipher[0]
                }
                //メモ
                /*
                    0x20 = 32
                    0x40 = 64
                    mload(p) : mem[p...(p+32))
                    mstore(p,v) : mem[p...(p+32)) := v

                */
                // free memory pointer
                /*let memPtr := mload(0x40)

                // length of base, exponent, modulus
                mstore(memPtr, 0x20)
                mstore(add(memPtr, 0x20), 0x20)
                mstore(add(memPtr, 0x40), 0x20)

                // assign base, exponent, modulus
                mstore(add(memPtr, 0x60), base)
                mstore(add(memPtr, 0x80), exponent)
                mstore(add(memPtr, 0xa0), modulus)

                // call the precompiled contract BigModExp (0x05)
                let success := call(gas, 0x05, 0x0, memPtr, 0xc0, memPtr, 0x20)
                switch success
                case 0 {
                    revert(0x0, 0x0)
                } default {
                    result := mload(memPtr)
                }*/
                
                
                // call the precompiled contract BigModExp (0x05)
                
            }
        }
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

