// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./NodeSales.sol";

contract Methods is NodeSales {

    constructor(
        address handlerContract_,
        string memory name_, 
        string memory symbol_
    ) NodeSales(handlerContract_, name_, symbol_) {}

    function mint(address currency, string memory referralCode, uint16 quantity) nonReentrant external payable {
        require(canMint, "Mint is not available yet");
        require(acceptedCurrencies[currency], "Currency not accepted");
        uint256 finalPrice = price;

        if (referralCodes[referralCode].active) {
            ReferralCode memory ref = referralCodes[referralCode];
            finalPrice -= (price * ref.discountPercentage) / 100;
            if (ref.affiliatePercentage > 0 && ref.affiliate != address(0)) {
                uint256 affiliateReward = (price * ref.affiliatePercentage) / 100;
                affiliateEarnings[ref.affiliate][currency] += affiliateReward * quantity;
            }
        }

        if (currency == address(0)) {
            require(msg.value >= finalPrice * quantity, "Insufficient ETH sent");
        } else {
            IERC20(currency).transferFrom(msg.sender, address(this), finalPrice * quantity);
        }

        for (uint16 i = 0 ; i < quantity ; ++i) {
            _mint(msg.sender, nextTokenId);
            emit LicenseMinted(msg.sender, nextTokenId);
            nextTokenId++;
        }
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function setCanMint(bool _canMint) external onlyOwner {
        canMint = _canMint;
    }

    function setFundsReceiver(address _receiver) external onlyOwner {
        fundsReceiver = _receiver;
    }

    function withdrawFunds(address token) nonReentrant external {
        uint256 balance;
        address receiver = msg.sender == owner() ? fundsReceiver : msg.sender;
        if (token == address(0)) {
            balance = receiver == owner() ? address(this).balance : affiliateEarnings[receiver][token];
            // Withdraw native ETH
            payable(receiver).transfer(balance);
            emit FundsWithdrawn(receiver, token, balance);
        } else {
            // Withdraw ERC-20 token balance
            IERC20 tokenContract = IERC20(token);
            uint256 tokenBalance = tokenContract.balanceOf(address(this));
            balance = receiver == owner() ? tokenBalance : affiliateEarnings[receiver][token];
            require(balance > 0, "No token balance to withdraw");
            tokenContract.transfer(receiver, balance);
            emit FundsWithdrawn(receiver, token, balance);
        }

        if (receiver != owner()) {
            affiliateEarnings[receiver][token] -=balance;
        }
    }

    function toggleTransferability(bool _state) external onlyOwner {
        transferable = _state;
    }

    function burn(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function createReferralCode(
        string memory code,
        uint16 discountPercentage,
        uint16 affiliatePercentage,
        address affiliate
    ) external onlyOwner {
        require(affiliatePercentage <= discountPercentage, "AP must be <= than DP");
        referralCodes[code] = ReferralCode(affiliate, discountPercentage, affiliatePercentage, true);
        emit ReferralCodeCreated(code, discountPercentage, affiliatePercentage, affiliate);
    }

    function disableReferralCode(string memory code) external onlyOwner {
        referralCodes[code].active = false;
    }

    function addAcceptedCurrency(address currency) external onlyOwner {
        acceptedCurrencies[currency] = true;
    }

    function removeAcceptedCurrency(address currency) external onlyOwner {
        acceptedCurrencies[currency] = false;
    }
}
