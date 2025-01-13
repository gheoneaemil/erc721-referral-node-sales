// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ERC20Token = buildModule("ERC20Token", (m: any) => {
  const deployed = m.contract("ERC20Token", [1000000000000000]);

  return { deployed };
});

export default ERC20Token;
