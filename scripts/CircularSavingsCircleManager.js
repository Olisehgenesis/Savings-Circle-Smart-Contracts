const ethers = require('ethers');
const CircleFactoryABI = require('../artifacts/contracts/CircleFactory.sol/CircleFactory.json');
const CircularSavingsCircleABI = require('../artifacts/contracts/CircularSavingsCircle.sol/CircularSavingsCircle.json');

class CircularSavingsCircleManager {
  constructor(providerUrl, circleFactoryAddress, privateKey) {
    this.provider = new ethers.JsonRpcProvider(providerUrl);
    this.wallet = new ethers.Wallet(privateKey, this.provider);
    this.circleFactory = new ethers.Contract(circleFactoryAddress, CircleFactoryABI['abi'], this.wallet);
  }

  async createCircularSavingsCircle(roundDuration, contributionAmount, fee) {
    const tx = await this.circleFactory.createCircularSavingsCircle(
      roundDuration,
      ethers.utils.parseUnits(contributionAmount.toString(), 6), // Assuming 6 decimal places for USDC
      ethers.utils.parseUnits(fee.toString(), 6), // Assuming 6 decimal places for USDC
      { value: ethers.utils.parseEther("0.1") } // 0.1 ETH for gas fee, adjust as needed
    );
    const receipt = await tx.wait();
    const event = receipt.events.find(e => e.event === 'CircleCreated');
    return event.args.circleAddress;
  }

  async contribute(circleAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    const tx = await circle.contribute();
    await tx.wait();
  }

  async addMember(circleAddress, memberAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    const tx = await circle.addMember(memberAddress);
    await tx.wait();
  }

  async checkAndDistribute(circleAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    const tx = await circle.checkAndDistribute();
    await tx.wait();
  }

  async getCurrentRound(circleAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    return await circle.currentRound();
  }

  async getMembers(circleAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    const memberCount = await circle.getMemberCount();
    const members = [];
    for (let i = 0; i < memberCount; i++) {
      members.push(await circle.members(i));
    }
    return members;
  }

  async getRoundDuration(circleAddress) {
    const circle = new ethers.Contract(circleAddress, CircularSavingsCircleABI, this.wallet);
    return await circle.roundDuration();
  }
}

module.exports = CircularSavingsCircleManager;