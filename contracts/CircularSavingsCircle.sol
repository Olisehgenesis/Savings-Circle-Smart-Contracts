// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./SavingsCircle.sol";

contract CircularSavingsCircle is SavingsCircle {
    uint256 public roundDuration;
    uint256 public fee;
    uint256 public currentRound;
    uint256 public lastDistributionTime;

    event Distribution(address recipient, uint256 amount);

    constructor(
        address _centralStorage,
        uint256 _minimumContributionAmount,
        uint256 _roundDuration,
        uint256 _fee
    ) SavingsCircle(_centralStorage, _minimumContributionAmount) {
        roundDuration = _roundDuration;
        fee = _fee;
        lastDistributionTime = block.timestamp;
        currentRound = 0;
    }

    function _afterContribution(address user, uint256 amount) internal override {
        checkAndDistribute();
    }

    function checkAndDistribute() public {
        if (block.timestamp >= lastDistributionTime + roundDuration && members.length > 0) {
            distribute();
        }
    }

    function distribute() private {
        address recipient = members[currentRound % members.length];
        uint256 totalAmount = centralStorage.getUserBalance(address(this));
        uint256 amountToDistribute = totalAmount - fee;

        centralStorage.transferFunds(address(this), recipient, amountToDistribute);
        centralStorage.transferFunds(address(this), owner(), fee);

        emit Distribution(recipient, amountToDistribute);

        currentRound++;
        lastDistributionTime = block.timestamp;
    }
}