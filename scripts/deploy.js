const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const Token = await hre.ethers.getContractFactory("ERC20Mock");
  const token0 = await Token.deploy("Token A", "TKA", hre.ethers.parseEther("1000000"));
  const token1 = await Token.deploy("Token B", "TKB", hre.ethers.parseEther("1000000"));
  await token0.waitForDeployment();
  await token1.waitForDeployment();

  const Swap = await hre.ethers.getContractFactory("EclipseSwap");
  const swap = await Swap.deploy(token0.address, token1.address);
  await swap.waitForDeployment();

  console.log("Token0:", token0.address);
  console.log("Token1:", token1.address);
  console.log("EclipseSwap:", swap.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
