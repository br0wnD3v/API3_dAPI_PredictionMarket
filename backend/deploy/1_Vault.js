module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, get } = deployments;
  const { deployer } = await getNamedAccounts();

  const usdc = await get("MockUSDC");

  await deploy("PM_Vault", {
    from: deployer,
    args: [usdc.address],
    log: true,
  });
};
module.exports.tags = ["Vault"];
