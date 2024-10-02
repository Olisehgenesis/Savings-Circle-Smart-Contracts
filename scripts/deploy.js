const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Deploy MockStableToken (for testing purposes)
  const MockStableToken = await hre.ethers.getContractFactory("MockStableToken");
  const mockStableToken = await MockStableToken.deploy("Mock USDC", "mUSDC", 6);
  await mockStableToken.waitForDeployment();
  console.log("MockStableToken deployed to:", await mockStableToken.getAddress());

  // Deploy StorageFactory
  const StorageFactory = await hre.ethers.getContractFactory("StorageFactory");
  const storageFactory = await StorageFactory.deploy();
  await storageFactory.waitForDeployment();
  console.log("StorageFactory deployed to:", await storageFactory.getAddress());

  // Deploy CircleFactory
  const CircleFactory = await hre.ethers.getContractFactory("CircleFactory");
  const circleFactory = await CircleFactory.deploy(
    await storageFactory.getAddress(),
    await mockStableToken.getAddress()
  );
  await circleFactory.waitForDeployment();
  console.log("CircleFactory deployed to:", await circleFactory.getAddress());

  // Create a Fixed Savings Circle
  const createFixedTx = await circleFactory.createFixedSavingsCircle(
    hre.ethers.parseUnits("100", 6), // 100 USDC minimum contribution
    10 // 10 rounds
  );
  const fixedReceipt = await createFixedTx.wait();
  const fixedEvent = fixedReceipt.logs.find(log => log.eventName === 'FixedSavingsCircleCreated');
  console.log("Fixed Savings Circle created at:", fixedEvent.args.circleAddress);

  // Create a Circular Savings Circle
  const createCircularTx = await circleFactory.createCircularSavingsCircle(
    hre.ethers.parseUnits("100", 6), // 100 USDC minimum contribution
    604800, // 1 week round duration
    hre.ethers.parseUnits("1", 6) // 1 USDC fee
  );
  const circularReceipt = await createCircularTx.wait();
  const circularEvent = circularReceipt.logs.find(log => log.eventName === 'CircularSavingsCircleCreated');
  console.log("Circular Savings Circle created at:", circularEvent.args.circleAddress);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });