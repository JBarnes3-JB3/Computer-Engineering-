import { ethers } from "ethers";
import { readFileSync } from "fs";

const artifact = JSON.parse(readFileSync("./artifacts/contracts/FlightInsurance.sol/FlightInsurance.json", "utf8"));
const contractAddress = readFileSync("contract_address.txt", "utf8").trim();

function parseWeather(filePath) {
    const lines = readFileSync(filePath, "utf8").trim().split("\n");
    const weather = {};
    for (let i = 1; i < lines.length; i++) {
        const parts = lines[i].trim().split(/\s+/);
        const date      = parts[0];
        const city      = parts[1];
        const condition = parts[2];
        weather[`${date}_${city}`] = condition;
    }
    return weather;
}

async function main() {
    const provider = new ethers.JsonRpcProvider("http://127.0.0.1:8545");
    const providerSigner = await provider.getSigner(0); // account[0] is insurance provider
    const contract = new ethers.Contract(contractAddress, artifact.abi, providerSigner);

    const weatherMap  = parseWeather("weather.txt");
    const BAD_WEATHER = ["Hail", "Flood"];

    console.log("Weather data loaded:");
    console.log(weatherMap);

    console.log("\nFetching all policies from blockchain...");
    const result = await contract.view_all_policies();

    const addresses  = result[0];
    const names      = result[1];
    const flightNums = result[2];
    const dates      = result[3];
    const departures = result[4];
    const statuses   = result[6];

    console.log(`Found ${addresses.length} policies.\n`);

    for (let i = 0; i < addresses.length; i++) {
        if (statuses[i] !== "purchased") {
            console.log(`[SKIP] ${names[i]} — already ${statuses[i]}`);
            continue;
        }

        const key       = `${dates[i]}_${departures[i]}`;
        const condition = weatherMap[key] || "Unknown";

        console.log(`[CHECK] ${names[i]} | ${flightNums[i]} | ${departures[i]} on ${dates[i]} → ${condition}`);

        if (BAD_WEATHER.includes(condition)) {
            console.log(`  Extreme weather! Paying 0.02 ETH to ${addresses[i]}...`);

            const balBefore = await provider.getBalance(addresses[i]);

            const tx = await contract.pay_indemnity(
                addresses[i],
                { value: ethers.parseEther("0.02") }
            );
            await tx.wait();

            const balAfter = await provider.getBalance(addresses[i]);
            console.log(`  Paid! Tx: ${tx.hash}`);
            console.log(`  Balance before: ${ethers.formatEther(balBefore)} ETH`);
            console.log(`  Balance after:  ${ethers.formatEther(balAfter)} ETH\n`);
        } else {
            console.log(`  No extreme weather — no payout.\n`);
        }
    }

    console.log("Done.");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
