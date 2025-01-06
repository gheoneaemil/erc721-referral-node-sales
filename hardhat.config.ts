import "@typechain/hardhat";
import { HardhatUserConfig } from "hardhat/config";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
    solidity: "0.8.19",
    typechain: {
        outDir: "typechain-types",
        target: "ethers-v5",
    }
};

export default config;
