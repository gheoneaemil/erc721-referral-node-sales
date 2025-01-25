import { ethers, ignition } from "hardhat";
import NodeSale from "../ignition/modules/NodeSale";

async function deployAndInteract() {
  const deployment = await ignition.deploy(NodeSale, {});

  // Get the deployed Root contract
  const rootContract = await ethers.getContractAt("Root", String(deployment.root.target));

  // Call the handlerContract view method
  const handlerContractResult = await rootContract.handlerContract();
  const owner = await rootContract.owner();
  console.log("Root contract: ", deployment.root.target);
  console.log("Methods contract: ", deployment.methods.target);
  console.log("Result of handlerContract:", handlerContractResult);
  console.log("Owner: ", owner);
}

deployAndInteract().catch((error) => {
  console.error("Error during deployment or interaction:", error);
  process.exit(1);
});