const hre = require("hardhat");
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  //get stable and price feed from .env
  const StableTokenAddress = process.env.StableTokenAddress
  const EthUsdPriceFeedAddress = process.env.EthUsdPriceFeedAddress

  console.log("Deploying contracts with the account:", deployer.address);

  const CircleFactory = await hre.ethers.getContractFactory("CircleFactory");
  const circleFactory = await CircleFactory.deploy(
    StableTokenAddress,
    EthUsdPriceFeedAddress
);

  await circleFactory.getAddress();

  console.log("CircleFactory deployed to:", circleFactory.getAddress());
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });