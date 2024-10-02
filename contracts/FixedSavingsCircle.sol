// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SavingsCircle.sol";

contract FixedSavingsCircle is SavingsCircle {
    uint256 public totalRounds;
    uint256 public currentRound;
    mapping(address => bool) public hasWithdrawn;

    event RoundCompleted(uint256 roundNumber);
    event Withdrawal(address member, uint256 amount);

    constructor(
        address _centralStorage,
        uint256 _minimumContributionAmount,
        uint256 _totalRounds
    ) SavingsCircle(_centralStorage, _minimumContributionAmount) {
        totalRounds = _totalRounds;
        currentRound = 0;
    }

    function _afterContribution(address /* user */, uint256 /* amount */) internal override {
        if (currentRound < totalRounds) {
            currentRound++;
            emit RoundCompleted(currentRound);
        }
    }

    function withdraw() public {
        require(currentRound == totalRounds, "Saving period not finished");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        require(isMember[msg.sender], "Not a member");

        uint256 balance = centralStorage.getUserBalance(msg.sender);
        require(balance > 0, "No balance to withdraw");

        hasWithdrawn[msg.sender] = true;
        centralStorage.withdrawFunds(msg.sender, balance);
        emit Withdrawal(msg.sender, balance);
    }
}