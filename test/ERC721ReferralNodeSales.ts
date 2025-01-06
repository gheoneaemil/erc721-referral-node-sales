import { expect } from "chai";
import { Signer } from "ethers";
import { ERC721ReferralNodeSales } from "../typechain-types";
import "@nomicfoundation/hardhat-chai-matchers";
const { ethers } = require("hardhat");

describe("ERC721ReferralNodeSales Smart Contract", function () {
    let contract: ERC721ReferralNodeSales;
    let owner: Signer, addr1: Signer, addr2: Signer;

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        const NodeLicenseFactory = await ethers.getContractFactory("NodeLicense");
        contract = await NodeLicenseFactory.deploy();
        await contract.deployed();
    });

    describe("Minting", function () {
        it("should mint a new token and emit event", async function () {
            const price = ethers.utils.parseEther("1");
            await contract.setPrice(price);
            await expect(
                contract.connect(addr1).mint(ethers.constants.AddressZero, "")
            ).to.emit(contract, "LicenseMinted");
        });

        it("should fail if insufficient ETH is sent", async function () {
            const price = ethers.utils.parseEther("1");
            await contract.setPrice(price);
            await expect(
                contract.connect(addr1).mint(ethers.constants.AddressZero, "", { value: price.sub(1) })
            ).to.be.revertedWith("Insufficient ETH sent");
        });
    });

    describe("Referral Codes", function () {
        it("should create a referral code and apply discount", async function () {
            await contract.createReferralCode("TESTCODE", 10, 0, ethers.constants.AddressZero);
            const price = ethers.utils.parseEther("1");
            await contract.setPrice(price);

            await expect(
                contract.connect(addr1).mint(ethers.constants.AddressZero, "TESTCODE", { value: price.mul(9).div(10) })
            ).to.emit(contract, "LicenseMinted");
        });

        it("should fail if referral code is inactive", async function () {
            await contract.createReferralCode("TESTCODE", 10, 0, ethers.constants.AddressZero);
            await contract.disableReferralCode("TESTCODE");

            const price = ethers.utils.parseEther("1");
            await contract.setPrice(price);

            await expect(
                contract.connect(addr1).mint(ethers.constants.AddressZero, "TESTCODE", { value: price })
            ).to.be.reverted;
        });
    });

    describe("Transferability", function () {
        it("should disable transfers when toggled off", async function () {
            await contract.toggleTransferability(false);

            await expect(
                contract.transferFrom(await owner.getAddress(), await addr1.getAddress(), 1)
            ).to.be.revertedWith("Transfers are disabled");
        });
    });

    describe("Funds Management", function () {
        it("should allow the owner to withdraw funds", async function () {
            const price = ethers.utils.parseEther("1");
            await contract.setPrice(price);

            await contract.connect(addr1).mint(ethers.constants.AddressZero, "", { value: price });

            const initialBalance = await ethers.provider.getBalance(await owner.getAddress());
            await contract.withdrawFunds();
            const finalBalance = await ethers.provider.getBalance(await owner.getAddress());

            expect(finalBalance).to.be.gt(initialBalance);
        });
    });
});
