const ethers = require('ethers');
const CircleFactoryABI = require('../artifacts/contracts/CircleFactory.sol/CircleFactory.json');
const FixedSavingsCircleABI = require('../artifacts/contracts/FixedSavingsCircle.sol/FixedSavingsCircle.json');

class FixedSavingsCircleManager {
  constructor(providerUrl, circleFactoryAddress, privateKey) {
    console.log("Address:", circleFactoryAddress);

    this.provider = new ethers.JsonRpcProvider(providerUrl);
    this.wallet = new ethers.Wallet(privateKey, this.provider);
    this.circleFactory = new ethers.Contract(circleFactoryAddress, CircleFactoryABI.abi, this.wallet);
  }


  async createFixedSavingsCircle(totalRounds, contributionAmount) {
    console.log(`Creating Fixed Savings Circle with ${totalRounds} rounds and ${contributionAmount} contribution amount`);
    
    return new Promise((resolve, reject) => {
      // Set up event listener before sending the transaction
      const filter = this.circleFactory.filters.FixedSavingsCircleCreated();
      
      const listener = (creator, circleAddress, event) => {
        console.log(`New Fixed Savings Circle created by ${creator} at: ${circleAddress}`);
        
        // Remove the listener to prevent memory leaks
        this.circleFactory.off(filter, listener);
        
        resolve(circleAddress);
      };

      this.circleFactory.on(filter, listener);

      // Create the fixed savings circle
      this.circleFactory.createFixedSavingsCircle(
        totalRounds,
        ethers.parseUnits(contributionAmount.toString(), 6), // Assuming 6 decimal places for USDC
        { value: ethers.parseEther("0.1") } // 0.1 ETH for gas fee, adjust as needed
      ).then(tx => {
        console.log('Transaction sent:', tx.hash);
        return tx.wait();
      }).then(receipt => {
        console.log('Transaction mined. Receipt:', receipt);
      }).catch(error => {
        // Remove the listener in case of error
        this.circleFactory.off(filter, listener);
        reject(error);
      });

      // Set a timeout in case the event is not emitted
      setTimeout(() => {
        this.circleFactory.off(filter, listener);
        reject(new Error("Timeout: FixedSavingsCircleCreated event not received"));
      }, 60000); // 60 seconds timeout
    });
  }
  async getDeployedCircles() {
    const deployedCircles = await this.circleFactory.getDeployedCircles();
    console.log("Deployed circles:", deployedCircles);
  }


  async contribute(circleAddress, contributionAmount) {
    console.log(`Contributing ${contributionAmount} to Fixed Savings Circle at: ${circleAddress}`);
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.wallet);
    
    let amount = ethers.parseUnits(contributionAmount.toString(), 6); // Assuming 6 decimal places for USDC
    const tx = await circle.contribute(amount);
    await tx.wait();

    console.log("Contribution successful", tx);
    return tx;
  }

  async withdraw(circleAddress) {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.wallet);
    const tx = await circle.withdraw();
    await tx.wait();
  }

  async getBalance(circleAddress) {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.wallet);
    const balance = await circle.balances(this.wallet.address);
    return ethers.formatUnits(balance, 6); // Assuming 6 decimal places for USDC
  }

  async getCurrentRound(circleAddress) {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.wallet);
    return await circle.currentRound();
  }

  async getTotalRounds(circleAddress) {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.wallet);
    return await circle.totalRounds();
  }

  // Method to listen for all events from a specific circle
  listenToCircleEvents(circleAddress) {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.provider);
    circle.on("*", (event) => {
      console.log("Event received:", event.eventName);
      console.log("Event details:", event);
    });
  }

  // Method to query historic events
  async queryHistoricEvents(circleAddress, eventName, fromBlock = 0, toBlock = 'latest') {
    const circle = new ethers.Contract(circleAddress, FixedSavingsCircleABI.abi, this.provider);
    const filter = circle.filters[eventName]();
    const events = await circle.queryFilter(filter, fromBlock, toBlock);
    return events.map(event => ({
      eventName: event.eventName,
      args: event.args,
      blockNumber: event.blockNumber,
      transactionHash: event.transactionHash
    }));
  }
}

module.exports = FixedSavingsCircleManager;