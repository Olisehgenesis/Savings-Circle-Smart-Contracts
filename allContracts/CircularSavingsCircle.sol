// File: CircularSavingsCircle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SavingsCircle.sol";

contract CircularSavingsCircle is SavingsCircle {
    uint256 public roundDuration;
    uint256 public fee;
    uint256 public currentRound;
    uint256 public lastDistributionTime;
    address[] public members;

    constructor(
        address _admin,
        uint256 _roundDuration,
        uint256 _contributionAmount,
        uint256 _fee,
        address _stableTokenAddress
    ) payable SavingsCircle(_admin, _contributionAmount, _stableTokenAddress) {
        roundDuration = _roundDuration;
        fee = _fee;
        lastDistributionTime = block.timestamp;
    }

    function addMember(address member) public {
        require(msg.sender == admin, "Only admin can add members");
        members.push(member);
    }

    function checkAndDistribute() public {
        if (block.timestamp >= lastDistributionTime + roundDuration && members.length > 0) {
            distribute();
        }
    }

    function distribute() private {
        uint256 totalAmount = stableToken.balanceOf(address(this));
        uint256 amountToDistribute = totalAmount - fee;
        address recipient = members[currentRound % members.length];

        require(stableToken.transfer(recipient, amountToDistribute), "Stable token transfer to recipient failed");
        require(stableToken.transfer(admin, fee), "Stable token fee transfer failed");

        currentRound++;
        lastDistributionTime = block.timestamp;
    }

    function contribute() public override {
        super.contribute();
        checkAndDistribute();
    }

    function withdraw() public override {
        revert("Use contribute() to participate. Distribution is automatic.");
    }
}
