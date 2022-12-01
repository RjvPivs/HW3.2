// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Other {
    constructor(){

    }
    address private ad;
    bool private sc;
    function otherSetHost(address other) external{
        (sc, ) = other.call(
            abi.encodeWithSignature("setHost()")
        );
    }

    function otherExtractHost(address other) external {
        (bool success, bytes memory host) = other.call(
            abi.encodeWithSignature("checkHost()")
        );
        ad = abi.decode(host, (address));
    }
    function otherGetHost() external view returns(address){
        return ad;
    }
    function otherSetHostStatus() external view returns(bool){
        return sc;
    }
}