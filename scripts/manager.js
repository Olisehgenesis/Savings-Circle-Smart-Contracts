const FixedSavingsCircleManager = require('./FixedSavingsCircleManager');
const CircularSavingsCircleManager = require('./CircularSavingsCircleManager');
require("dotenv").config();

const providerUrl = 'https://sepolia.base.org'; // Base Sepolia RPC URL
const circleFactoryAddress = process.env.CIRCLE_FACTORY_ADDRESS;
const privateKey = process.env.PRIVATE_KEY;

const fixedManager = new FixedSavingsCircleManager(providerUrl, circleFactoryAddress, privateKey);
const circularManager = new CircularSavingsCircleManager(providerUrl, circleFactoryAddress, privateKey);
const fixedCircleAddress = process.env.FIXED_SAVINGS_CIRCLE_ADDRESS;
async function main() {
  // Create a new Fixed Savings Circle
  // const fixedCircleAddress = await fixedManager.createFixedSavingsCircle(10, 100);
  // console.log('New Fixed Savings Circle created at:', fixedCircleAddress);

//   // Create a new Circular Savings Circle
//   const circularCircleAddress = await circularManager.createCircularSavingsCircle(86400, 100, 1);
//   console.log('New Circular Savings Circle created at:', circularCircleAddress);

  // Contribute to the Fixed Savings Circle
  await fixedManager.contribute(fixedCircleAddress, 1);
  console.log('Contributed to Fixed Savings Circle');

//   // Contribute to the Circular Savings Circle
//   await circularManager.contribute(circularCircleAddress);
//   console.log('Contributed to Circular Savings Circle');

  // ... other operations ...
}

main().catch(console.error);