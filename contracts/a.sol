pragma solidity ^0.5.0;

contract Proxy {
  
  function () payable external {  //①
    _fallback();
  }
  
  function _implementation() internal view returns (address);

  function _delegate(address implementation) internal {  //③
    assembly {
      calldatacopy(0, 0, calldatasize)  // a

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)  // b

      returndatacopy(0, 0, returndatasize)  // c
      switch result  // d
   
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  function _willFallback() internal {
  }

  function _fallback() internal {  //②
    _willFallback();
    _delegate(_implementation());
  }
}
