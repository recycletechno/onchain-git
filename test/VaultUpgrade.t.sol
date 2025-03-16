// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/VaultImplementationV1.sol";
import "../src/VaultImplementationV2.sol";
import "../src/VersionControlBeacon.sol";
import "../src/VaultFactory.sol";
import "../src/VaultProxy.sol";

contract VaultUpgradeTest is Test {
    VersionControlBeacon public beacon;
    VaultFactory public factory;
    VaultImplementationV1 public implementationV1;
    VaultImplementationV2 public implementationV2;
    
    address[] public vaults;
    string constant TOKEN_NAME = "Token1";
    
    function setUp() public {
        implementationV1 = new VaultImplementationV1();
        
        beacon = new VersionControlBeacon(address(implementationV1));
        
        factory = new VaultFactory(address(beacon));
        
        for (uint i = 0; i < 3; i++) {
            address vault = factory.createVault(TOKEN_NAME);
            vaults.push(vault);
        }
    }
    
    function testInitialDeployment() public {
        assertEq(beacon.implementation(), address(implementationV1));
        
        assertEq(factory.getVaultCount(), 3);
        
        VaultImplementationV1 vault = VaultImplementationV1(vaults[0]);
        vault.deposit(100);
        assertEq(vault.getBalance(), 100);
    }
    
    function testUpgradeToV2() public {
        implementationV2 = new VaultImplementationV2();
        
        beacon.upgradeTo(address(implementationV2));
        
        assertEq(beacon.implementation(), address(implementationV2));
        
        // Test deposit on the first vault (should still work after upgrade)
        VaultImplementationV2 vault = VaultImplementationV2(vaults[0]);
        vault.deposit(100);
        assertEq(vault.getBalance(), 100);
        
        // Test new withdraw function (only available in V2)
        vault.withdraw(50);
        assertEq(vault.getBalance(), 50);
    }
    
    function testRollback() public {
        implementationV2 = new VaultImplementationV2();
        beacon.upgradeTo(address(implementationV2));
        
        beacon.rollbackTo(0);
        
        assertEq(beacon.implementation(), address(implementationV1));
        
        VaultImplementationV1 vault = VaultImplementationV1(vaults[0]);
        vault.deposit(100);
        assertEq(vault.getBalance(), 100);
        
        // Trying to call withdraw function should fail since we rolled back to V1
        (bool success, ) = vaults[0].call(
            abi.encodeWithSignature("withdraw(uint256)", 50)
        );
        assertFalse(success);
    }
    
    function testMultipleVersions() public {
        implementationV2 = new VaultImplementationV2();
        
        beacon.upgradeTo(address(implementationV2));
        
        assertEq(beacon.getVersionCount(), 2);
        
        address mockV3 = makeAddr("MockV3");
        
        beacon.upgradeTo(mockV3);
        
        // Verify version count increased
        assertEq(beacon.getVersionCount(), 3);
        
        // Rollback to V2
        beacon.rollbackTo(1);
        assertEq(beacon.implementation(), address(implementationV2));
    }
    
    function testAllVaultsUpgradedTogether() public {
        // Initial deposit on all vaults
        for (uint i = 0; i < vaults.length; i++) {
            VaultImplementationV1 vault = VaultImplementationV1(vaults[i]);
            vault.deposit(200);
            assertEq(vault.getBalance(), 200);
        }
        
        // Upgrade to V2
        implementationV2 = new VaultImplementationV2();
        beacon.upgradeTo(address(implementationV2));
        
        // All vaults should have withdraw functionality now
        for (uint i = 0; i < vaults.length; i++) {
            VaultImplementationV2 vault = VaultImplementationV2(vaults[i]);
            
            // Verify balance persisted through upgrade
            assertEq(vault.getBalance(), 200);
            
            // Test withdraw function
            vault.withdraw(50);
            assertEq(vault.getBalance(), 150);
        }
    }
} 