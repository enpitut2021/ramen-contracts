//テストinput
/*
[message](青木さんのテストケースにあった)
0x97d035e32036a670058f2be4e008a7c56355489750a5da6f2af342db4a968e99

[signature](青木さんのテストケースにあった)
0x866B66D33D512E5D4BBE37A92EFE3B94FAC8C36A914A4E18CA265F60FD10EF99BE3ECA7D1DB6726FEB2CEAA13A8D4162DD54AE605BBA73CF5ACE1F944901791C14B2E73CCD1271CE8D28B6EF2E0452703B8CD26B5CAA16DE695B0C239FBACC3B63B57358EF8794C84EF5FFEA2C54593CA3533E6FAFBB1A966D0730F1F2ACDFF7FC84786A89DE95AFA595D4589F6CE7DFF017193F8E2540684778277B7C2AB0F0F8324B7A355990CAF459948B6B5B97F6F00D0684178A84328A88384904FD5723BC51A0532053E39B996366B440177585ABCE3D163FE0C544CF9BA0E4FAEEB282460BF2B009A0AFC217430434C27941EF3123095BA0D19E6C10DCB4046201159B

[e](青木さんのテストケースのmynaPubkeyDerをderファイルにしてopensslで内容を見た)
0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001

[n](eと同じ)
0xc2e48c45c07363e246be44407c8af5317cbccd3aa8be5d26129224525ac9fd73bc65296102d48744600952f0493c397657c966e2564ff9ef5175357eec9628036096326107a90bd538f67390aaecbcd85672bdc66f088b3f1fa0657009c146dbec38111c50757358e3016803cf5ece665927b377afdf058432a624b372d2e39cf534ab9ed449da12ba239fe0dd96f65c72ccea6b6bfd9733c41e90edee1f842078ac5cde7c95c6242a322516ef22927f35abb8afe8327633d7ded0959384d205853b84726fabed29182f0213b6a74f118651d2c4c415b8253d3ac2d339c8775361b6201849fe99626f591f558c5c916a79182c856bb1599ad12be5d33748e799
*/

//参考資料
//RFC8017 : https://datatracker.ietf.org/doc/html/rfc8017#section-8.2.2
//RSASSA-PKCS1-V1_5 : http://blog.livedoor.jp/k_urushima/archives/979220.html
//EIP198(1) : https://eips.ethereum.org/EIPS/eip-198
//EIP198(2) : https://github.com/adria0/SolRsaVerify/blob/master/contracts/SolRsaVerify.sol


pragma solidity ^0.5.0;

contract Proxy {
    ////////////////////////////////////////////////////////////////////////////////
    ////                    8.2.2の2    入力がデカすぎなのでEIP198で計算            ////
    ////                    EIP198をbigModExpで実現                              ////
    ////////////////////////////////////////////////////////////////////////////////
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
    function createInput(bytes memory _s, bytes memory _e, bytes memory _m) pure internal returns (bytes memory) {
        uint inputLen = 32*3+256*3;
        uint sp;
        uint ep;
        uint mp;
        uint inputPtr;
        bytes memory input = new bytes(inputLen);
        assembly {
            sp := add(_s,0x20)
            ep := add(_e,0x20)
            mp := add(_m,0x20)
            mstore(add(input,0x20),256)
            mstore(add(input,0x40),256)
            mstore(add(input,0x60),256)
            inputPtr := add(input,0x20)
        }
        memcpy(inputPtr+32*3,sp,256);
        memcpy(inputPtr+32*3+256,ep,256);
        memcpy(inputPtr+32*3+256*2,mp,256);
        return input;
    }
    function bigModExp(bytes memory _s, bytes memory _e, bytes memory _m) public returns (bytes memory result) {
        bytes memory input = createInput(_s,_e,_m);
        uint inputlen = 32*3+256*3;
        uint anslen = 256;
        bytes memory ans = new bytes(anslen);
        assembly {
            let success := staticcall(sub(gas(), 2000), 5, add(input,0x20), inputlen, add(ans,0x20), anslen)
            switch success
            case 0 {
                revert(0x0, 0x0)
            } default {
                result := ans
            }
        }
    }

    function makeM(bytes memory _s, bytes memory _e, bytes memory _n)public returns(bytes memory){
        //エラー処理
        //require(0 <= _s && _s < _n-1,"invalid signature");
        return bigModExp(_s,_e,_n);//s^e mod n
    }

    /////////////////////////////////////////////////////////////////////////////
    ////                       8.2.2の3   (9.2)                              ////
    /////////////////////////////////////////////////////////////////////////////

    // #9.2 Step1.
    //平文messageはすでにハッシュ化済なので省略

    // #9.2 Step2.
    function connect(bytes memory _H) public returns(bytes memory){
        bytes19 byte1 = 0x3031300d060960864801650304020105000420;
        bytes memory byte2 = _H;
        bytes memory connect = new bytes(byte1.length + byte2.length);
        uint8 point = 0;
        for(uint8 j = 0; j < byte1.length;j++){
            connect[point] = byte1[j];
            point++;
        }
        for(uint8 k = 0; k < byte2.length;k++){
            connect[point] = byte2[k];
            point++;
        }
        return connect;
    }
    // #9.2 Step4.
    function makePS(uint256 pslen) public returns(bytes memory){
        bytes memory ps = new bytes(pslen);
        uint8 point = 0;
        for(uint8 j = 0; j < pslen;j++){
            ps[point] = 0xff;
            point++;
        }
        return ps;
    }
    // #9.2 Step5.
    // EM = 0x00 || 0x01 || PS || 0x00 || T.
    function connectEM(bytes memory _ps,bytes memory _t) public returns(bytes memory){
        bytes1 byte00 = 0x00;
        bytes1 byte01 = 0x01;
        bytes memory ps = _ps;
        bytes memory t = _t;
        bytes memory em = new bytes(byte00.length*2 + byte01.length + ps.length + t.length);
        em[0]=byte00;
        em[1]=byte01;
        uint8 point = 2;
        for(uint8 j = 0; j < ps.length;j++){
            em[point] = ps[j];
            point++;
        }
        em[point] = byte00;
        point++;
        for(uint8 k = 0; k < t.length;k++){
            em[point] = t[k];
            point++;
        }
        return em;
    }
    function EMSA_PKCS1_V1_5_ENCODE(bytes memory _m, uint256 emLen) public returns(bytes memory){
        // #9.2 Step1. (_mがhash済なので省略)
        // #9.2 Step2.
        bytes memory H = _m;
        bytes memory T;
        uint256 tLen;
        T = connect(H);
        tLen=T.length;
        // #9.2 Step3.
        //require(emLen < tLen+11,"intended encoded message length too short");
        // #9.2 Step4.
        uint256 psLen;
        psLen = emLen-tLen-3;
        bytes memory PS;
        PS = makePS(psLen);
        // #9.2 Step5.
        bytes memory em;
        em = connectEM(PS,T);
        // #9.2 Step6.
        return em;
    }


    //////////////////////////////////////////////////////////////////////////
    ////                       8.2.2の4                                   ////
    //////////////////////////////////////////////////////////////////////////
    function verifySignature(bytes memory message, bytes memory signature,bytes memory e, bytes memory n)public returns(bool){
        bytes memory EM;
        EM = makeM(signature,e,n);
        bytes memory em;
        em = EMSA_PKCS1_V1_5_ENCODE(message,256);

        if(EM.length!=em.length)//長さ比較
            return false;
        else
            return sha256(EM) == sha256(em);//hash値比較

        /*エラーになる
        if(EM.length!=em.length)
            return false;
        else{
            bool flag=true;
            for(uint8 i = 0; i < 256 && flag;i++){
                if(EM[i] != em[i])
                    flag=false;
            }
            if(flag)
                return true;
            else
                return false;
        }
        */
    }

}
