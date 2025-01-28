// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../deps/NodeSales.sol";

contract Root is NodeSales {

    constructor(
        address handlerContract_,
        string memory name_, 
        string memory symbol_
    ) NodeSales(handlerContract_, name_, symbol_) {}

    function mint(
        address currency, 
        string memory referralCode, 
        uint16 quantity
    ) external payable {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function setPrice(
        uint256 _price
    ) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function setCanMint(bool _canMint) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function setFundsReceiver(address _receiver) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function withdrawFunds(address token) external {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function toggleTransferability(bool _state) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function burn(uint256 tokenId) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function createReferralCode(
        string memory code,
        uint16 discountPercentage,
        uint16 affiliatePercentage,
        address affiliate
    ) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function disableReferralCode(string memory code) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function addAcceptedCurrency(address currency) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }

    function removeAcceptedCurrency(address currency) external onlyOwner {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
    }
}
