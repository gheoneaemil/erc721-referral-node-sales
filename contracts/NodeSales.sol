// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NodeSales is ReentrancyGuard, Ownable, ERC721 {
    uint256 public price;
    address public fundsReceiver;
    address public handlerContract;
    bool public transferable = true;
    bool public canMint = true;
    uint256 public _nextTokenId;

    struct ReferralCode {
        address affiliate;
        uint16 discountPercentage;
        uint16 affiliatePercentage;
        bool active;
    }

    mapping(string => ReferralCode) public referralCodes;
    mapping(address => mapping(address => uint256)) public affiliateEarnings;
    mapping(address => bool) public acceptedCurrencies;

    event LicenseMinted(address indexed buyer, uint256 tokenId);
    event ReferralCodeCreated(string code, uint16 discountPercentage, uint16 affiliatePercentage, address affiliate);
    event FundsWithdrawn(address receiver, address indexed token, uint256 amount);

    constructor(
        address handlerContract_, 
        string memory name_, 
        string memory symbol_
    ) 
        Ownable(msg.sender) 
        ERC721(name_, symbol_) 
    {
        _nextTokenId = 1;
        fundsReceiver = msg.sender;
        handlerContract = handlerContract_;
    }

    modifier onlyTransferable() {
        require(transferable, "Transfers are disabled");
        _;
    }

    modifier delegated() {
        (bool success, ) = handlerContract.delegatecall(msg.data);
        require(success);
        _;
    }

    function setHandlerContract(address handlerContract_) onlyOwner external {
        handlerContract = handlerContract_;
    }

    function transferFrom(address from, address to, uint256 tokenId) onlyTransferable public override {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) onlyTransferable public override {
        super.safeTransferFrom(from, to, tokenId, data);
    }
}
