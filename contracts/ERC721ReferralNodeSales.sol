// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC721ReferralNodeSales is ERC721Enumerable, Ownable, UUPSUpgradeable {
    uint256 public price;
    address public fundsReceiver;
    bool public transferable = true;
    uint256 private _nextTokenId;

    struct ReferralCode {
        uint256 discountPercentage;
        uint256 affiliatePercentage;
        address affiliate;
        bool active;
    }

    mapping(string => ReferralCode) public referralCodes;
    mapping(address => uint256) public affiliateEarnings;
    mapping(address => bool) public acceptedCurrencies;

    event LicenseMinted(address indexed buyer, uint256 tokenId);
    event ReferralCodeCreated(string code, uint256 discountPercentage, uint256 affiliatePercentage, address affiliate);
    event FundsWithdrawn(address receiver, uint256 amount);

    constructor() ERC721("NodeLicense", "NODE") {
        _nextTokenId = 1;
        fundsReceiver = msg.sender;
    }

    modifier onlyTransferable() {
        require(transferable, "Transfers are disabled");
        _;
    }

    function mint(address currency, string memory referralCode) external payable {
        require(acceptedCurrencies[currency], "Currency not accepted");
        uint256 finalPrice = price;

        if (referralCodes[referralCode].active) {
            ReferralCode memory ref = referralCodes[referralCode];
            finalPrice -= (price * ref.discountPercentage) / 100;
            if (ref.affiliatePercentage > 0 && ref.affiliate != address(0)) {
                uint256 affiliateReward = (finalPrice * ref.affiliatePercentage) / 100;
                affiliateEarnings[ref.affiliate] += affiliateReward;
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

    function setFundsReceiver(address _receiver) external onlyOwner {
        fundsReceiver = _receiver;
    }

    function withdrawFunds() external onlyOwner {
        payable(fundsReceiver).transfer(address(this).balance);
        emit FundsWithdrawn(fundsReceiver, address(this).balance);
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

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override onlyTransferable {}
}
