const ethers = require('ethers');
const CircleFactoryABI = require('../artifacts/contracts/CircleFactory.sol/CircleFactory.json');
const FixedSavingsCircleABI = require('../artifacts/contracts/FixedSavingsCircle.sol/FixedSavingsCircle.json');

require("dotenv").config();

const providerUrl = 'https://sepolia.base.org'; // Base Sepolia RPC URL
const circleFactoryAddress = process.env.CIRCLE_FACTORY_ADDRESS;
const privateKey = process.env.PRIVATE_KEY;
class FactoryMethods {
  constructor(providerUrl, circleFactoryAddress, privateKey) {
    console.log("Address:", circleFactoryAddress);

    this.provider = new ethers.JsonRpcProvider(providerUrl);
    this.wallet = new ethers.Wallet(privateKey, this.provider);
    this.circleFactory = new ethers.Contract(circleFactoryAddress, CircleFactoryABI.abi, this.wallet);
  }

  async getDeployedCircles() {
    const deployedCircles = await this.circleFactory.getDeployedCircles();
    console.log("Deployed circles:", deployedCircles);
  }
}
//run main
(async () => {
  const factory = new FactoryMethods(providerUrl, circleFactoryAddress, privateKey);
  await factory.getDeployedCircles();
})();

