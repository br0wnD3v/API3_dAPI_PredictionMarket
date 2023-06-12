module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const usdc = await get("MockUSDC");

  await deploy("PredictionMarket", {
    from: deployer,
    args: [usdc.address],
    log: true,
  });
};
module.exports.tags = ["Trading"];
