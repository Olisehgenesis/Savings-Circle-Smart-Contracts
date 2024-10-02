// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./SavingsCircle.sol";

contract CentralStorage is Ownable {
    IERC20 public stableToken;
    mapping(address => uint256) public userBalances;
    mapping(address => address) public userVirtualAddresses;
    mapping(address => address) public virtualToUserAddress;
    mapping(address => address) public virtualToCircle;
    mapping(address => uint256) public virtualAddressBalances;

    event VirtualAddressCreated(address user, address virtualAddress);
    event FundsReceived(address virtualAddress, uint256 amount);
    event ContributionMade(address user, address circle, uint256 amount);

    constructor(address _stableTokenAddress) Ownable(msg.sender) {
        stableToken = IERC20(_stableTokenAddress);
    }

    function createVirtualAddress(address user, address circle) external onlyOwner returns (address) {
        require(userVirtualAddresses[user] == address(0), "Virtual address already exists");
        address virtualAddress = address(uint160(uint256(keccak256(abi.encodePacked(user, block.timestamp)))));
        userVirtualAddresses[user] = virtualAddress;
        virtualToUserAddress[virtualAddress] = user;
        virtualToCircle[virtualAddress] = circle;
        emit VirtualAddressCreated(user, virtualAddress);
        return virtualAddress;
    }

    function receiveFunds(address virtualAddress, uint256 amount) external {
        require(stableToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");
        virtualAddressBalances[virtualAddress] += amount;
        emit FundsReceived(virtualAddress, amount);

        address user = virtualToUserAddress[virtualAddress];
        address circle = virtualToCircle[virtualAddress];
        uint256 contributionAmount = SavingsCircle(circle).minimumContributionAmount();

        while (virtualAddressBalances[virtualAddress] >= contributionAmount) {
            virtualAddressBalances[virtualAddress] -= contributionAmount;
            userBalances[user] += contributionAmount;
            emit ContributionMade(user, circle, contributionAmount);
            SavingsCircle(circle).notifyContribution(user, contributionAmount);
        }
    }

    function transferFunds(address from, address to, uint256 amount) external onlyOwner {
        require(userBalances[from] >= amount, "Insufficient balance");
        userBalances[from] -= amount;
        userBalances[to] += amount;
    }

    function withdrawFunds(address user, uint256 amount) external onlyOwner {
        require(userBalances[user] >= amount, "Insufficient balance");
        userBalances[user] -= amount;
        require(stableToken.transfer(user, amount), "Transfer failed");
    }

    function getUserBalance(address user) external view returns (uint256) {
        return userBalances[user];
    }

    function getVirtualAddressBalance(address virtualAddress) external view returns (uint256) {
        return virtualAddressBalances[virtualAddress];
    }

    function getUserAddress(address virtualAddress) external view returns (address) {
        return virtualToUserAddress[virtualAddress];
    }
}