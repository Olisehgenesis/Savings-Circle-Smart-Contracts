// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CentralStorage.sol";
import "./FixedSavingsCircle.sol";
import "./CircularSavingsCircle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SaccoFactory is Ownable {
    CentralStorage public centralStorage;
    address[] public deployedSaccos;
    
    event FixedSaccoCreated(address saccoAddress, uint256 minimumContribution, uint256 totalRounds);
    event CircularSaccoCreated(address saccoAddress, uint256 minimumContribution, uint256 roundDuration, uint256 fee);

    constructor(address _centralStorageAddress) Ownable(msg.sender) {
        centralStorage = CentralStorage(_centralStorageAddress);
    }

    function createFixedSavingsCircle(
        uint256 _minimumContributionAmount,
        uint256 _totalRounds
    ) public returns (address) {
        FixedSavingsCircle newSacco = new FixedSavingsCircle(
            address(centralStorage),
            _minimumContributionAmount,
            _totalRounds
        );
        deployedSaccos.push(address(newSacco));
        newSacco.transferOwnership(msg.sender);
        emit FixedSaccoCreated(address(newSacco), _minimumContributionAmount, _totalRounds);
        return address(newSacco);
    }

    function createCircularSavingsCircle(
        uint256 _minimumContributionAmount,
        uint256 _roundDuration,
        uint256 _fee
    ) public returns (address) {
        CircularSavingsCircle newSacco = new CircularSavingsCircle(
            address(centralStorage),
            _minimumContributionAmount,
            _roundDuration,
            _fee
        );
        deployedSaccos.push(address(newSacco));
        newSacco.transferOwnership(msg.sender);
        emit CircularSaccoCreated(address(newSacco), _minimumContributionAmount, _roundDuration, _fee);
        return address(newSacco);
    }

    function getDeployedSaccos() public view returns (address[] memory) {
        return deployedSaccos;
    }

    function getSaccoCount() public view returns (uint256) {
        return deployedSaccos.length;
    }

    function setCentralStorage(address _newCentralStorage) public onlyOwner {
        centralStorage = CentralStorage(_newCentralStorage);
    }
}