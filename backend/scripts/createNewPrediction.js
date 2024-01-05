const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  address: tradingAddress,
  abi: tradingABI,
} = require("../deployments/mumbai/PredictionMarket.json");
const {
  address: usdcAddress,
  abi: usdcABI,
} = require("../deployments/mumbai/MockUSDC.json");

const { ethers } = require("ethers");

// const PROVIDER = process.env.MUMBAI_RPC
const PROVIDER = process.env.MUMBAI_RPC;
const DEPLOYER = process.env.PK_DEPLOYER;

const provider = new ethers.providers.JsonRpcProvider(PROVIDER);
const wallet = new ethers.Wallet(DEPLOYER, provider);

const trading = new ethers.Contract(tradingAddress, tradingABI, wallet);
const usdc = new ethers.Contract(usdcAddress, usdcABI, wallet);

async function allowance() {
  const toApprove = 50000000n;
  try {
    const txn = await usdc.approve(tradingAddress, toApprove);
    const receipt = await txn.wait(1);
    console.log(receipt);
  } catch (err) {
    console.error(err);
  }
}

async function create(
  symbol,
  proxyAddress,
  isAbove,
  targetPrice,
  deadline,
  basePrice
) {
  try {
    const txn = await trading.createPrediction(
      symbol,
      proxyAddress,
      isAbove,
      targetPrice,
      deadline,
      basePrice,
      {
        gasLimit: 10000000,
      }
    );
    const receipt = await txn.wait(1);
    console.log(receipt);
  } catch (err) {
    console.error(err);
  }
}

async function main() {
  await allowance();

  const coder = ethers.utils.defaultAbiCoder;

  const symbol = ethers.utils.formatBytes32String("BTC");
  const proxyAddress = "0xba7892c114743bFd39F7A76180CacC93bAcC67e0";
  const isAbove = coder.encode(["bool"], [false]);
  const targetPrice = ethers.utils.parseUnits("45000", "ether").toString();
  const deadline = "1704499999";
  const basePrice = "110";

  console.log(
    "\n",
    symbol,
    proxyAddress,
    isAbove,
    targetPrice,
    deadline,
    basePrice,
    "\n"
  );
  await create(symbol, proxyAddress, isAbove, targetPrice, deadline, basePrice);
}

main();
