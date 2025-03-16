// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/VersionControlBeacon.sol";

contract RollbackToVersion is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address beaconAddress = vm.envAddress("BEACON_ADDRESS");
        uint256 versionIndex = vm.envUint("VERSION_INDEX");
        
        vm.startBroadcast(deployerPrivateKey);

        VersionControlBeacon beacon = VersionControlBeacon(beaconAddress);
        
        address currentImpl = beacon.implementation();
        console.log("Current implementation:", currentImpl);
        
        beacon.rollbackTo(versionIndex);
        console.log("Rolled back to version index:", versionIndex);
        
        address newImpl = beacon.implementation();
        console.log("New implementation:", newImpl);
        
        vm.stopBroadcast();
    }
} 