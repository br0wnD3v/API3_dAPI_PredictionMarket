const path = require("path");
require("dotenv").config({ path: path.join(__dirname, "..", ".env") });

const {
  abi: handlerABI,
} = require("../deployments/mumbai/PM_MarketHandler.json");
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

const amount = 10n * 1000000n;

const handlerAddress = "0x2d977db8697081457037aBB65d88Ac9134f7634F";
const usdc = new ethers.Contract(usdcAddress, usdcABI, wallet);
const marketHandler = new ethers.Contract(handlerAddress, handlerABI, wallet);

async function allowance() {
  // const I_BASE_PRICE = await marketHandler.I_BASE_PRICE();
  // const I_DECIMALS = await marketHandler.I_DECIMALS();
  // (_amount * I_BASE_PRICE) / I_DECIMALS;

  const toApprove = 500000000n;
  try {
    const txn = await usdc.approve(handlerAddress, toApprove);
    const receipt = await txn.wait(1);
    console.log("Approved.");
  } catch (err) {
    console.error(err);
  }
}

async function buy() {
  try {
    const txn = await marketHandler.buyYesToken(amount);
    const receipt = await txn.wait(1);
    console.log(receipt);
  } catch (err) {
    console.error(err);
  }
}

async function main() {
  await allowance();
  await buy();
}

main();
