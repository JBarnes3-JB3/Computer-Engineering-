import { ethers } from "ethers";
import fs from "fs";
import { readFileSync } from "fs";

// Read ABI and bytecode from compiled artifacts
const artifact = JSON.parse(readFileSync("./artifacts/contracts/FlightInsurance.sol/FlightInsurance.json", "utf8"));

async function main() {
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
    const accounts = await provider.listAccounts();
    const deployer = await provider.getSigner(0);

    console.log("Deploying with account:", await deployer.getAddress());

    const factory  = new ethers.ContractFactory(artifact.abi, artifact.bytecode, deployer);
    const contract = await factory.deploy();
    await contract.waitForDeployment();

    const address = await contract.getAddress();
    console.log("FlightInsurance deployed to:", address);

    fs.writeFileSync("contract_address.txt", address);
    console.log("Address saved to contract_address.txt");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
