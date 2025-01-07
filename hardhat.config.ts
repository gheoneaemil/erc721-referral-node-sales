import "@typechain/hardhat";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";
import "@nomicfoundation/hardhat-ignition";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
    solidity: {
        compilers: [
            { version: "0.8.28", settings: { optimizer: { enabled: true, runs: 200 } } },  // For your existing contracts
            { version: "0.8.21", settings: { optimizer: { enabled: true, runs: 200 } } }   // For OpenZeppelin 5.x dependencies
        ]
    },
    typechain: {
        outDir: "typechain-types",
        target: "ethers-v5",
    },
    networks: {
        arbitrumSepolia: {
            url: process.env.ARBITRUM_SEPOLIA_RPC_URL || "",
            accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
            chainId: 421614
        },
        hardhat: {
            chainId: 31337, // Hardhat local network chainId
        },
    },
    etherscan: {
        apiKey: process.env.ETHERSCAN_API_KEY || ""
    }, 
    sourcify: {
        enabled: true
    }
};

export default config;
