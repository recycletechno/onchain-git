// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IVault {
    function initialize(string memory tokenName) external;
    function deposit(uint256 amount) external;
    function getBalance() external view returns (uint256);
} 