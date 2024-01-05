const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  address: tradingAddress,
  abi: tradingABI,
} = require("../deployments/mumbai/PredictionMarket.json");

const { ethers } = require("ethers");

// const PROVIDER = process.env.MUMBAI_RPC
const PROVIDER = process.env.MUMBAI_RPC;
const DEPLOYER = process.env.PK_DEPLOYER;

const provider = new ethers.providers.JsonRpcProvider(PROVIDER);
const wallet = new ethers.Wallet(DEPLOYER, provider);

const trading = new ethers.Contract(tradingAddress, tradingABI, wallet);

async function get(id) {
  const data = await trading.getPrediction(id);
  console.log(data);
}

async function main() {
  get(1);
}

main();
