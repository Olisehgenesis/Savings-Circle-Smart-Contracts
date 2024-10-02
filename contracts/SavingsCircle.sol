// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./CentralStorage.sol";

abstract contract SavingsCircle is Ownable {
    CentralStorage public centralStorage;
    uint256 public minimumContributionAmount;
    mapping(address => bool) public isMember;
    address[] public members;

    event MemberAdded(address member);
    event MemberJoined(address member);
    event Contribution(address member, uint256 amount);

    constructor(address _centralStorage, uint256 _minimumContributionAmount) Ownable(msg.sender) {
        centralStorage = CentralStorage(_centralStorage);
        minimumContributionAmount = _minimumContributionAmount;
    }

    function addMember(address member) public onlyOwner {
        require(!isMember[member], "Already a member");
        isMember[member] = true;
        members.push(member);
        centralStorage.createVirtualAddress(member, address(this));
        emit MemberAdded(member);
    }

    function join() public {
        require(!isMember[msg.sender], "Already a member");
        isMember[msg.sender] = true;
        members.push(msg.sender);
        centralStorage.createVirtualAddress(msg.sender, address(this));
        emit MemberJoined(msg.sender);
    }

    function notifyContribution(address user, uint256 amount) external {
        require(msg.sender == address(centralStorage), "Only central storage can notify");
        require(isMember[user], "Not a member");
        emit Contribution(user, amount);
        _afterContribution(user, amount);
    }

    function _afterContribution(address user, uint256 amount) internal virtual;

    function getMemberCount() public view returns (uint256) {
        return members.length;
    }

    function isMemberAddress(address account) public view returns (bool) {
        return isMember[account];
    }

    function getVirtualAddress(address member) public view returns (address) {
        return centralStorage.userVirtualAddresses(member);
    }
}