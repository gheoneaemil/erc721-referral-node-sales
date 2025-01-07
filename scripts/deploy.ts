import { ethers, run, network } from "hardhat";
import * as dotenv from "dotenv";
dotenv.config();

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log(`Deploying contract with account: ${deployer.address}`);

    const CustomERC721 = await ethers.getContractFactory("CustomERC721");
    const contract: any = await CustomERC721.deploy();
    await contract.deployed();
    console.log(`Contract deployed to: ${contract.address}`);

    // Verify on Arbitrum Sepolia
    if (network.name === "arbitrumSepolia") {
        console.log("Waiting for block confirmations...");
        await contract.deployTransaction.wait(6);
        await verify(contract.address, []);
    }
}

// Verification function with error handling
async function verify(contractAddress: string, args: any[]) {
    console.log("Verifying contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
        console.log("Contract verified successfully!");
    } catch (error: any) {
        console.error("Verification error:", error.message);
    }
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
