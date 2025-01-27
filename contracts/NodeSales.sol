// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../deps/IERC20.sol";
import "../deps/ReentrancyGuard.sol";
import "../deps/Ownable.sol";
import "../deps/ERC721.sol";
import "./IGetMintPrice.sol";

contract NodeSales is ReentrancyGuard, Ownable, ERC721 {
    uint256 public price;
    address public fundsReceiver;
    address public handlerContract;
    bool public transferable = true;
    bool public canMint = true;
    uint256 public nextTokenId;

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
        nextTokenId = 1;
        fundsReceiver = msg.sender;
        handlerContract = handlerContract_;
    }

    modifier onlyTransferable() {
        require(transferable, "Transfers are disabled");
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
