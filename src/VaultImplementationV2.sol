// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";
import "./IVault.sol";

contract VaultImplementationV2 is IVault, Initializable {
    string public tokenName;
    uint256 internal _balance;
    
    function initialize(string memory _tokenName) public override initializer {
        tokenName = _tokenName;
    }
    
    function deposit(uint256 amount) public override {
        require(amount > 0, "Amount must be greater than 0");
        _balance += amount;
    }
  
    // Added a new function to withdraw tokens
    function withdraw(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        require(_balance >= amount, "Insufficient balance");
        _balance -= amount;
    }
    
    function getBalance() public view override returns (uint256) {
        return _balance;
    }
} 