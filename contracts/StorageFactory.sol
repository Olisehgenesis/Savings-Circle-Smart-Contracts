// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CentralStorage.sol";

contract StorageFactory {
    event StorageCreated(address storageAddress);

    function createStorage(address _stableTokenAddress) public returns (address) {
        CentralStorage newStorage = new CentralStorage(_stableTokenAddress);
        newStorage.transferOwnership(msg.sender);
        emit StorageCreated(address(newStorage));
        return address(newStorage);
    }
}