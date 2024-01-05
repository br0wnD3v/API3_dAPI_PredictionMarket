const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  address: settlementAddress,
  abi: settlementABI,
} = require("../deployments/mumbai/PM_Settlement.json");

const { ethers } = require("ethers");

// const PROVIDER = process.env.MUMBAI_RP
const PROVIDER = process.env.MUMBAI_RPC;
const DEPLOYER = process.env.PK_DEPLOYER;

const provider = new ethers.providers.JsonRpcProvider(PROVIDER);
const wallet = new ethers.Wallet(DEPLOYER, provider);

const settlement = new ethers.Contract(
  settlementAddress,
  settlementABI,
  wallet
);

async function conclude(id) {
  try {
    const txn = await settlement.concludePrediction_1(id, {
      gasLimit: 10000000,
    });
    const receipt = await txn.wait(1);
    console.log(receipt);
  } catch (err) {
    console.error(err);
  }
}

async function main() {
  await conclude(2);
}

main();
