const hre = require("hardhat");

async function main() {
  const MarketHandler = await hre.deployments.get("PredictionMarket");
  const tradingContract = new hre.ethers.Contract(Trading.address, Trading.abi, (await hre.ethers.getSigners())[0]);
  const amount = 10n * 1000000n;
  try {
    const txn = await tradingContract.buyYesToken(amount, {
      gasLimit: "100000",
    });
    const receipt = await txn.wait(1);
    if (receipt.status == 1) console.log("Success!");
  } catch (err) {
    console.error(err);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
