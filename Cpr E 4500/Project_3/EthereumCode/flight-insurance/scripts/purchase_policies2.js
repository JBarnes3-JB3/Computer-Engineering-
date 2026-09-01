import { ethers } from "ethers";
import { readFileSync } from "fs";

const artifact = JSON.parse(readFileSync("./artifacts/contracts/FlightInsurance.sol/FlightInsurance.json", "utf8"));
const contractAddress = readFileSync("contract_address.txt", "utf8").trim();

async function main() {
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");

    const passengers = [
        { index: 4, name: "Dave",  flight: "FL400", date: "2023-04-18", from: "Tampa",   to: "NYC"     },
        { index: 5, name: "Eve",   flight: "FL500", date: "2023-04-18", from: "Miami",   to: "Boston"  },
        { index: 6, name: "Frank", flight: "FL600", date: "2023-04-16", from: "Houston", to: "Phoenix" },
        { index: 7, name: "Grace", flight: "FL700", date: "2023-04-19", from: "Tucson",  to: "Dallas"  },
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
