const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  address: tradingAddress,
  abi: tradingABI,
} = require("../deployments/goerli/PredictionMarket.json");
const {
  address: usdcAddress,
  abi: usdcABI,
} = require("../deployments/goerli/MockUSDC.json");

const { ethers } = require("ethers");

const PROVIDER = process.env.GOERLI_RPC;
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
  const proxyAddress = "0xe5Cf15fED24942E656dBF75165aF1851C89F21B5";
  const isAbove = coder.encode(["bool"], [true]);
  const targetPrice = ethers.utils.parseUnits("27000", "ether").toString();
  const deadline = "1695382560";
  const basePrice = "120";

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
