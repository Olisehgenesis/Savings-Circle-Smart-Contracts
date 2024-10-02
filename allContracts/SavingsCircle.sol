// File: SavingsCircle.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract SavingsCircle {
    address public admin;
    uint256 public contributionAmount;
    IERC20 public stableToken;
    mapping(address => uint256) public balances;

    constructor(address _admin, uint256 _contributionAmount, address _stableTokenAddress) payable {
        admin = _admin;
        contributionAmount = _contributionAmount;
        stableToken = IERC20(_stableTokenAddress);
    }

    function contribute() public virtual {
        require(stableToken.transferFrom(msg.sender, address(this), contributionAmount), "Stable token transfer failed");
        balances[msg.sender] += contributionAmount;
    }

    function withdraw() public virtual;

    function emergencyWithdraw() public {
        require(msg.sender == admin, "Only admin can perform emergency withdrawal");
        uint256 balance = stableToken.balanceOf(address(this));
        require(stableToken.transfer(admin, balance), "Stable token transfer failed");
        payable(admin).transfer(address(this).balance);
    }
}
