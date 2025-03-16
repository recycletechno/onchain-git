// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/proxy/beacon/IBeacon.sol";

contract VersionControlBeacon is IBeacon, Ownable {
    address[] public versionHistory;
    
    address public currentVersion;
    
    event Upgraded(address indexed implementation);
    
    event RolledBack(address indexed implementation, uint256 versionIndex);
    
    constructor(address initialImplementation) Ownable(msg.sender) {
        require(initialImplementation != address(0), "Implementation cannot be zero address");
        versionHistory.push(initialImplementation);
        currentVersion = initialImplementation;
        emit Upgraded(initialImplementation);
    }
    
    function implementation() public view override returns (address) {
        return currentVersion;
    }
    
    function upgradeTo(address newImplementation) public onlyOwner {
        require(newImplementation != address(0), "Implementation cannot be zero address");
        versionHistory.push(newImplementation);
        currentVersion = newImplementation;
        emit Upgraded(newImplementation);
    }
    
    function rollbackTo(uint256 versionIndex) public onlyOwner {
        require(versionIndex < versionHistory.length, "Invalid version index");
        address prevImplementation = versionHistory[versionIndex];
        currentVersion = prevImplementation;
        emit RolledBack(prevImplementation, versionIndex);
    }
    
    function getVersionCount() public view returns (uint256) {
        return versionHistory.length;
    }
} 