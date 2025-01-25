// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { address0x0 } from "../../utils/constants";

const NodeSale = buildModule("Methods", (m: any) => {
  const methods = m.contract("Methods", [address0x0, "Node Sales", "NODES"]);
  const root = m.contract("Root", [methods, "Node Sales", "NODES"]);
  return { methods, root };
});

export default NodeSale;
