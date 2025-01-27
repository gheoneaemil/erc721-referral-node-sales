//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGetMintPrice {

    function getMintPrice(string memory referralCode) external view returns(uint256);

}