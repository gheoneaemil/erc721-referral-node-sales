// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ERC721ReferralNodeSales = buildModule("ERC721ReferralNodeSales", (m: any) => {
  const deployed = m.contract("ERC721ReferralNodeSales");

  return { deployed };
});

export default ERC721ReferralNodeSales;
