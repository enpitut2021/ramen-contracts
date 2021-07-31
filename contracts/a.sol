pragma solidity ^0.5.0;

// https://block-chain.jp/ethereum/proxy-contracts-1/
// https://tech.bitbank.cc/20201222/
contract Proxy {
  
  function () payable external {  //①
    _fallback();
  }
  
  function _implementation() internal view returns (address);

  // delegate callが実現できれば、このコントラクトから別のコントラクトを呼び出せる。
  // 呼び出し先のcontractの実行者は呼び出したEOAアドレス(msg.sender)となる。
  function _delegate(address implementation) internal {  //③
    assembly {
      // calldatasizeを使用してmsg.dataのサイズを取得し、calldatacopyを使用してmsg.dataをcalldata領域の0の位置にコピーします。
      calldatacopy(0, 0, calldatasize)  // a

      //関数の実行に必要なガス、呼び出し先コントラクトのアドレス（address implementationに格納されている。）、
      // 呼び出すメソッドのデータ（3つ目の引数場所で0となっている部分には、msg.dataが格納されている。）、
      // 渡すデータのサイズをdelegatecallの引数として渡し、外部呼び出しを行います。
      // 4・5番目の引数であるoutとoutsizeは、サイズがわからないため0です。
      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)  // b

      // returndatasizeで返されたデータのサイズを利用して、
      // 返されたデータの中身をcalldata領域の0の位置にコピーします。
      returndatacopy(0, 0, returndatasize)  // c
      // データを返します。エラー時に0を返します。
      switch result  // d
   
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  // そしてDelegatecallは、外部コントラクトの任意の関数を呼び出せる必要があります。
  // そのために①にFallback 関数が実装されています。
  // コントラクトはサポートしていな関数の呼び出しが行われると、fallback 関数を実行するようになっています。proxy contractでは特別なfallback 関数を用意して、外部コントラクトへの呼び出しをリダイレクトします。

  // fallback関数には名前がありません。主にコントラクトにETHを送金するために実装されます。
  // 引数を明示的に渡すことはできませんが、msg.dataを利用してfallbackのpayloadに直接任意のデータを渡すことが可能です。
  // これにより、delegatecallに呼び出したい関数やその引数の情報が渡せます。
  // またfallback関数は返り値が存在しないため、実行の成功の有無を論理値で返すように設定されています。

  // Fallback関数①、_fallback②、_delegate③の順に呼び出されます。
  function _willFallback() internal {
  }

  function _fallback() internal {  //②
    _willFallback();
    _delegate(_implementation());
  }
}
