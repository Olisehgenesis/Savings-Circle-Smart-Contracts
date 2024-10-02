# Savings Circle Smart Contracts

This project implements a decentralized savings circle system using smart contracts on the Ethereum blockchain, specifically deployed on the Base Sepolia testnet.

## Overview

The Savings Circle system allows users to create and participate in two types of savings circles:

1. Fixed Savings Circle: Members contribute a fixed amount for a set number of rounds.
2. Circular Savings Circle: Members contribute regularly, and the pool is distributed to one member each round.

## Contracts

### Deployed Contracts on Base Sepolia

- MockStableToken: `0x5B09e8eb6dBe8DAF03F995206E76884fB1FF7E21`
- StorageFactory: `0xE36cDE527DAFFd93C6C90Aa291a1bF193a636971`
- CircleFactory: `0x5629Dd9dD89741F46DEbEAe26C9Be5862829AE1D`
- Sample Fixed Savings Circle: `0xa6D45191A6c2468FC820EC02B11EC28D416D212a`
- Sample Circular Savings Circle: `0x2cd64c9e9b06A7F52A8264354c78dA23C26430ae`

### Contract Structures

1. **CircleFactory**: Creates new savings circles.
2. **StorageFactory**: Creates storage contracts for each savings circle.
3. **CentralStorage**: Manages funds and virtual addresses for each circle.
4. **SavingsCircle**: Base contract for savings circles.
5. **FixedSavingsCircle**: Implements fixed savings circle logic.
6. **CircularSavingsCircle**: Implements circular savings circle logic.

## Key Functions

### CircleFactory

- `createFixedSavingsCircle(uint256 _minimumContributionAmount, uint256 _totalRounds)`: Creates a new fixed savings circle.
- `createCircularSavingsCircle(uint256 _minimumContributionAmount, uint256 _roundDuration, uint256 _fee)`: Creates a new circular savings circle.
- `getDeployedCircles()`: Returns an array of all deployed circle addresses.
- `getDeployedCirclesCount()`: Returns the count of deployed circles.

### SavingsCircle (Base Contract)

- `addMember(address member)`: Adds a new member to the circle (admin only).
- `join()`: Allows a user to join the circle.
- `getVirtualAddress(address member)`: Returns the virtual address for a member.
- `getMemberCount()`: Returns the number of members in the circle.

### FixedSavingsCircle

- `withdraw()`: Allows members to withdraw their funds after the saving period is finished.

### CircularSavingsCircle

- `checkAndDistribute()`: Checks if it's time to distribute funds and does so if conditions are met.

### CentralStorage

- `receiveFunds(address virtualAddress, uint256 amount)`: Receives funds for a member's virtual address.
- `transferFunds(address from, address to, uint256 amount)`: Transfers funds between addresses (internal use).
- `withdrawFunds(address user, uint256 amount)`: Withdraws funds for a user.

## How It Can Be Helpful

1. **Financial Inclusion**: Provides a decentralized platform for communal saving, accessible to anyone with an Ethereum wallet.
2. **Transparency**: All transactions and distributions are recorded on the blockchain, ensuring transparency and trust.
3. **Automation**: Contributions and distributions are automated, reducing the need for manual management.
4. **Flexibility**: Supports both fixed and circular savings models, catering to different saving preferences.
5. **Security**: Funds are managed by smart contracts, reducing the risk of mismanagement or fraud.

## Potential Beneficiaries

1. **Microfinance Institutions**: Can use this system to manage group savings programs.
2. **Community Groups**: Can organize local savings circles without needing a centralized authority.
3. **Financial Education Initiatives**: Can use this as a practical tool to teach about saving and financial management.
4. **Remittance Services**: Can integrate this system to provide more options for immigrants sending money home.

## Areas for Improvement (Potential Pull Requests)

1. **Interest Mechanism**: Implement a way to earn interest on pooled funds.
2. **Multi-Token Support**: Allow circles to use different ERC20 tokens.
3. **Governance System**: Add voting mechanisms for circle decisions.
4. **Emergency Pause**: Implement a pause mechanism for emergencies.
5. **Member Reputation System**: Develop a system to track member reliability.
6. **Mobile-Friendly Interface**: Create a mobile app for easy access.
7. **KYC Integration**: Add optional KYC processes for regulatory compliance.
8. **Automated Reporting**: Generate financial reports for circle activities.
9. **Cross-Chain Functionality**: Extend the system to work across multiple blockchains.
10. **Smart Contract Upgradability**: Implement upgradable contracts for future improvements.

## Setup and Deployment

1. Clone the repository
2. Install dependencies: `npm install`
3. Set up `.env` file with your private key and RPC URL
4. Compile contracts: `npx hardhat compile`
5. Deploy contracts: `npx hardhat run scripts/deploy.js --network baseSepolia`

## Testing

Run tests with: `npx hardhat test`

## Contributing

We welcome contributions! Please see our contributing guidelines for more details.

## License

This project is licensed under the MIT License.
