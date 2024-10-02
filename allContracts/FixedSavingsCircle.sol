// File: FixedSavingsCircle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SavingsCircle.sol";

contract FixedSavingsCircle is SavingsCircle {
    uint256 public totalRounds;
    uint256 public currentRound;
    mapping(address => bool) public hasWithdrawn;
    address[] public members;

    constructor(address _admin, uint256 _totalRounds, uint256 _contributionAmount, address _stableTokenAddress)
        payable
        SavingsCircle(_admin, _contributionAmount, _stableTokenAddress)
    {
        totalRounds = _totalRounds;
    }

    function addMember(address member) public {
        require(msg.sender == admin, "Only admin can add members");
        members.push(member);
    }

    function contribute() public override {
        super.contribute();
        if (currentRound < totalRounds) {
            currentRound++;
        }
    }

    function withdraw() public override {
        require(currentRound == totalRounds, "Saving period not finished");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        hasWithdrawn[msg.sender] = true;
        require(stableToken.transfer(msg.sender, amount), "Stable token transfer failed");
    }
}
