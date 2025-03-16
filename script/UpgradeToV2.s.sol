// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/VaultImplementationV2.sol";
import "../src/VersionControlBeacon.sol";

contract UpgradeToV2 is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address beaconAddress = vm.envAddress("BEACON_ADDRESS");
        
        vm.startBroadcast(deployerPrivateKey);

        VaultImplementationV2 implementationV2 = new VaultImplementationV2();
        console.log("VaultImplementationV2 deployed at:", address(implementationV2));

        VersionControlBeacon beacon = VersionControlBeacon(beaconAddress);
        address currentImpl = beacon.implementation();
        console.log("Current implementation:", currentImpl);
        beacon.upgradeTo(address(implementationV2));
        console.log("Beacon upgraded to V2 implementation");
        
        address newImpl = beacon.implementation();
        console.log("New implementation:", newImpl);
        
        vm.stopBroadcast();
    }
} 