// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/master/contracts/proxy/utils/UUPSUpgradeable.sol";
import "https://github.com/openzeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/ReentrancyGuard.sol";

contract ERC721ReferralNodeSales is ERC721Enumerable, Ownable, UUPSUpgradeable, ReentrancyGuard {
    uint256 public price;
    address public fundsReceiver;
    bool public transferable = true;
    bool public canMint = true;
    uint256 private _nextTokenId;

    struct ReferralCode {
        uint256 discountPercentage;
        uint256 affiliatePercentage;
        address affiliate;
        bool active;
    }

    mapping(string => ReferralCode) public referralCodes;
    mapping(address => mapping(address => uint256)) public affiliateEarnings;
    mapping(address => bool) public acceptedCurrencies;

    event LicenseMinted(address indexed buyer, uint256 tokenId);
    event ReferralCodeCreated(string code, uint256 discountPercentage, uint256 affiliatePercentage, address affiliate);
    event FundsWithdrawn(address receiver, address indexed token, uint256 amount);

    constructor() Ownable(msg.sender) ERC721("NodeLicense", "NODE") {
        _nextTokenId = 1;
        fundsReceiver = msg.sender;
    }

    modifier onlyTransferable() {
        require(transferable, "Transfers are disabled");
        _;
    }

    function getMintPrice(string memory referralCode) external view returns(uint256) {
        uint256 finalPrice = price;
        ReferralCode memory ref = referralCodes[referralCode];
        
        if (referralCodes[referralCode].active) {    
            finalPrice -= (price * ref.discountPercentage) / 100;
        }
        
        return finalPrice;
    }

    function mint(address currency, string memory referralCode) nonReentrant external payable {
        require(canMint, "Mint is not available yet");
        require(acceptedCurrencies[currency], "Currency not accepted");
        uint256 finalPrice = price;

        if (referralCodes[referralCode].active) {
            ReferralCode memory ref = referralCodes[referralCode];
            finalPrice -= (price * ref.discountPercentage) / 100;
            if (ref.affiliatePercentage > 0 && ref.affiliate != address(0)) {
                uint256 affiliateReward = (price * ref.affiliatePercentage) / 100;
                affiliateEarnings[ref.affiliate][currency] += affiliateReward;
            }
        }

        if (currency == address(0)) {
            require(msg.value >= finalPrice, "Insufficient ETH sent");
        } else {
            IERC20(currency).transferFrom(msg.sender, address(this), finalPrice);
        }

        _mint(msg.sender, _nextTokenId);
        emit LicenseMinted(msg.sender, _nextTokenId);
        _nextTokenId++;
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
        uint256 discountPercentage,
        uint256 affiliatePercentage,
        address affiliate
    ) external onlyOwner {
        require(affiliatePercentage <= discountPercentage, "AP must be <= than DP");
        referralCodes[code] = ReferralCode(discountPercentage, affiliatePercentage, affiliate, true);
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

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _update(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override onlyTransferable {}
}
