module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const trading = await get("PredictionMarket");

  await deploy("PM_Settlement", {
    from: deployer,
    args: [trading.address],
    log: true,
  });
};
module.exports.tags = ["Trading"];
