import { ethers } from "ethers";
import { readFileSync } from "fs";

const artifact = JSON.parse(readFileSync("./artifacts/contracts/FlightInsurance.sol/FlightInsurance.json", "utf8"));
const contractAddress = readFileSync("contract_address.txt", "utf8").trim();

async function main() {
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

    const passengers = [
        { index: 1, name: "Alice", flight: "FL100", date: "2023-04-17", from: "Phoenix", to: "Dallas"  },
        { index: 2, name: "Bob",   flight: "FL200", date: "2023-04-15", from: "Denver",  to: "Chicago" },
        { index: 3, name: "Carol", flight: "FL300", date: "2023-04-15", from: "Austin",  to: "Seattle" },
    ];

    for (const p of passengers) {
        const signer   = await provider.getSigner(p.index);
        const contract = new ethers.Contract(contractAddress, artifact.abi, signer);

        console.log(`\nPurchasing policy for ${p.name} (${await signer.getAddress()})...`);

        const tx = await contract.purchase_policy(
            p.name, p.flight, p.date, p.from, p.to,
            { value: ethers.parseEther("0.01") }
        );
        await tx.wait();
        console.log(`  Done! Tx: ${tx.hash}`);

        const result = await contract.view_purchased_policy();
        console.log(`  Policy: Name=${result[0]}, Flight=${result[1]}, Date=${result[2]}, From=${result[3]}, To=${result[4]}, Status=${result[5]}`);
    }

    console.log("\nAll policies purchased.");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
