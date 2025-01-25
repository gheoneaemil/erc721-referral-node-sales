// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NodeSales.sol";

contract Root is NodeSales {

    constructor(
        address handlerContract_,
        string memory name_, 
        string memory symbol_
    ) NodeSales(handlerContract_, name_, symbol_) {}

    function getMintPrice(string memory referralCode) external view returns(bytes memory) {
        (bool success, bytes memory result) = handlerContract.staticcall(msg.data);
        require(success);
        return result;
    }

    function mint(
        address currency, 
        string memory referralCode, 
        uint16 quantity
    ) nonReentrant external payable delegated {}

    function setPrice(
        uint256 _price
    ) external onlyOwner delegated {}

    function setCanMint(bool _canMint) external onlyOwner delegated {}

    function setFundsReceiver(address _receiver) external onlyOwner delegated {}

    function withdrawFunds(address token) nonReentrant external delegated {}

    function toggleTransferability(bool _state) external onlyOwner delegated {}

    function burn(uint256 tokenId) external onlyOwner delegated {}

    function createReferralCode(
        string memory code,
        uint16 discountPercentage,
        uint16 affiliatePercentage,
        address affiliate
    ) external onlyOwner delegated {}

    function disableReferralCode(string memory code) external onlyOwner delegated {}

    function addAcceptedCurrency(address currency) external onlyOwner delegated {}

    function removeAcceptedCurrency(address currency) external onlyOwner delegated {}
}
