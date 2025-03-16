// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/VaultImplementationV1.sol";
import "../src/VersionControlBeacon.sol";
import "../src/VaultFactory.sol";

contract DeployVaults is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        VaultImplementationV1 implementation = new VaultImplementationV1();
        console.log("VaultImplementationV1 deployed at:", address(implementation));

        VersionControlBeacon beacon = new VersionControlBeacon(address(implementation));
        console.log("VersionControlBeacon deployed at:", address(beacon));

        VaultFactory factory = new VaultFactory(address(beacon));
        console.log("VaultFactory deployed at:", address(factory));

        string[3] memory tokenNames = ["Token1", "Token2", "Token3"];
        for (uint i = 0; i < 3; i++) {
            address vault = factory.createVault(tokenNames[i]);
            console.log("Vault for", tokenNames[i], "deployed at:", vault);
        }

        vm.stopBroadcast();
    }
} 