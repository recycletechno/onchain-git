// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./VaultProxy.sol";
import "./IVault.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

contract VaultFactory is Ownable {
    address public immutable beacon;
    
    address[] public deployedVaults;
    
    event VaultCreated(address indexed vaultAddress, string tokenName, uint256 index);
    
    constructor(address _beacon) Ownable(msg.sender) {
        require(_beacon != address(0), "Beacon cannot be zero address");
        beacon = _beacon;
    }
    
    function createVault(string memory tokenName) public onlyOwner returns (address vault) {
        // Calldata is used to pass the tokenName to the initialize function
        // Use interface to avoid using the implementation address (v1 or v2)
        bytes memory initData = abi.encodeWithSelector(
            IVault.initialize.selector,
            tokenName
        );
        
        VaultProxy newVault = new VaultProxy(beacon, initData);
        vault = address(newVault);
        
        deployedVaults.push(vault);
        emit VaultCreated(vault, tokenName, deployedVaults.length - 1);
    }
    
    function getVaultCount() public view returns (uint256) {
        return deployedVaults.length;
    }
    
    function getAllVaults() public view returns (address[] memory) {
        return deployedVaults;
    }
} 