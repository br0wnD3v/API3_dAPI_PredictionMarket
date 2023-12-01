const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  address: tradingAddress,
  abi: tradingABI,
} = require("../deployments/goerli/PredictionMarket.json");

const { ethers } = require("ethers");

// const PROVIDER = process.env.MUMBAI_RPC
const PROVIDER = process.env.GOERLI_RPC;
const DEPLOYER = process.env.PK_DEPLOYER;

const provider = new ethers.providers.JsonRpcProvider(PROVIDER);
const wallet = new ethers.Wallet(DEPLOYER, provider);

const amount = 10n * 1000000n;

const trading = new ethers.Contract(tradingAddress, tradingABI, wallet);

async function buy() {
  try {
    const txn = await trading.buyYesToken(amount, {
      gasLimit: 10000000,
    });
    const receipt = await txn.wait(1);
    if (receipt.status == 1) console.log("Success!");
  } catch (err) {
    console.error(err);
  }
}

async function main() {
  await buy();
}

main();
