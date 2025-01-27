import { expect } from "chai";
import { parseEther, Signer } from "ethers";
import "@nomicfoundation/hardhat-chai-matchers";
import { address0x0 } from "../utils/constants";
const { ethers } = require("hardhat");

const oneWei = parseEther("1000000");

describe("ERC721ReferralNodeSales Smart Contract", function () {
    let root: any;
    let methods: any;
    let owner: Signer, addr1: Signer, addr2: Signer;

    before(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();

        root = await ethers.deployContract("Root", [address0x0, "test", "t"]);
        await root.waitForDeployment();

        const rootAddress = await root.getAddress();
        
        methods = await ethers.deployContract("Methods", [rootAddress, "test", "t"]);
        await methods.waitForDeployment();
    });

    describe("Minting", function () {
        it("should use the methods address on root contract", async function() {
            const originalAddress = await methods.getAddress();
            await root.setHandlerContract(originalAddress);
            const address = await root.handlerContract();
            console.log(address, originalAddress);
            expect(address).to.be.eq(originalAddress);
        });

        it("should mint a new token and emit event", async function () {
            await root.setPrice(oneWei);
            const nextTokenIdBefore = await root.nextTokenId();
            await root.connect(addr1).mint(address0x0, "", 1, { value: 1 });
            const nextTokenIdAfter = await root.nextTokenId();
            console.log(nextTokenIdBefore, nextTokenIdAfter);
            await expect(nextTokenIdBefore).to.be.lt(nextTokenIdAfter);
        });

        it("should fail if insufficient ETH is sent", async function () {
            await root.setPrice(oneWei);
            await expect(
                root.connect(addr1).mint(ethers.constants.AddressZero, "", 1, { value: oneWei })
            ).to.be.revertedWith("Insufficient ETH sent");
        });
    });

    describe("Referral Codes", function () {
        it("should create a referral code and apply discount", async function () {
            await root.createReferralCode("TESTCODE", 10, 0, ethers.constants.AddressZero);
            await root.setPrice(oneWei);
            await expect(
                root.connect(addr1).mint(ethers.constants.AddressZero, "TESTCODE", 1, { value: oneWei })
            ).to.emit(root, "LicenseMinted");
        });

        it("should fail if referral code is inactive", async function () {
            await root.createReferralCode("TESTCODE", 10, 0, ethers.constants.AddressZero);
            await root.disableReferralCode("TESTCODE");
            await root.setPrice(oneWei);
            await expect(
                root.connect(addr1).mint(ethers.constants.AddressZero, "TESTCODE", 1, { value: oneWei })
            ).to.be.reverted;
        });
    });

    describe("Transferability", function () {
        it("should disable transfers when toggled off", async function () {
            await root.toggleTransferability(false);
            await expect(
                root.transferFrom(await owner.getAddress(), await addr1.getAddress(), 1)
            ).to.be.revertedWith("Transfers are disabled");
        });
    });

    describe("Funds Management", function () {
        it("should allow the owner to withdraw funds", async function () {
            await root.setPrice(oneWei);
            await root.connect(addr1).mint(ethers.constants.AddressZero, "", 1, { value: oneWei });
            const initialBalance = await ethers.provider.getBalance(await owner.getAddress());
            await root.withdrawFunds(address0x0);
            const finalBalance = await ethers.provider.getBalance(await owner.getAddress());
            expect(finalBalance).to.be.gt(initialBalance);
        });
    });
});
