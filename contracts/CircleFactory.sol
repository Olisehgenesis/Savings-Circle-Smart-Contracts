// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./StorageFactory.sol";
import "./FixedSavingsCircle.sol";
import "./CircularSavingsCircle.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CircleFactory is Ownable {
    StorageFactory public storageFactory;
    address public stableTokenAddress;
    address[] public deployedCircles;
    
    event CircularSavingsCircleCreated(address circleAddress, address storageAddress, uint256 minimumContribution, uint256 roundDuration, uint256 fee);
    event FixedSavingsCircleCreated(address circleAddress, address storageAddress, uint256 minimumContribution, uint256 totalRounds);

    constructor(address _storageFactoryAddress, address _stableTokenAddress) Ownable(msg.sender) {
        storageFactory = StorageFactory(_storageFactoryAddress);
        stableTokenAddress = _stableTokenAddress;
    }

    function createCircularSavingsCircle(
        uint256 _minimumContributionAmount,
        uint256 _roundDuration,
        uint256 _fee
    ) public returns (address) {
        address newStorageAddress = storageFactory.createStorage(stableTokenAddress);
        
        CircularSavingsCircle newCircle = new CircularSavingsCircle(
            newStorageAddress,
            _minimumContributionAmount,
            _roundDuration,
            _fee
        );
        deployedCircles.push(address(newCircle));
        newCircle.transferOwnership(msg.sender);
        emit CircularSavingsCircleCreated(address(newCircle), newStorageAddress, _minimumContributionAmount, _roundDuration, _fee);
        return address(newCircle);
    }

    function createFixedSavingsCircle(
        uint256 _minimumContributionAmount,
        uint256 _totalRounds
    ) public returns (address) {
        address newStorageAddress = storageFactory.createStorage(stableTokenAddress);
        
        FixedSavingsCircle newCircle = new FixedSavingsCircle(
            newStorageAddress,
            _minimumContributionAmount,
            _totalRounds
        );
        deployedCircles.push(address(newCircle));
        newCircle.transferOwnership(msg.sender);
        emit FixedSavingsCircleCreated(address(newCircle), newStorageAddress, _minimumContributionAmount, _totalRounds);
        return address(newCircle);
    }

    function getDeployedCircles() public view returns (address[] memory) {
        return deployedCircles;
    }

    function getDeployedCirclesCount() public view returns (uint256) {
        return deployedCircles.length;
    }

    function setStorageFactory(address _newStorageFactory) public onlyOwner {
        storageFactory = StorageFactory(_newStorageFactory);
    }

    function setStableTokenAddress(address _newStableTokenAddress) public onlyOwner {
        stableTokenAddress = _newStableTokenAddress;
    }
}