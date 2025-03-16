# Version Control System for Upgradeable Smart Contract

This project implements a version control system for upgradeable smart contracts using the Beacon Proxy pattern.

## Overview

The system consists of:

- **VersionControlBeacon**: Maintains a history of all implementation addresses and allows for upgrades and rollbacks.
- **VaultImplementationV1**: First implementation with deposit functionality.
- **VaultImplementationV2**: Second implementation that adds withdrawal functionality.
- **VaultProxy**: A proxy contract that delegates calls to the implementation determined by the beacon.
- **VaultFactory**: A factory for deploying multiple vault proxies that share the same beacon.

## Deployment

### 1. Deploy initial contracts (V1)

Set your private key in the `.env` file:
```
PRIVATE_KEY=your_private_key_here
```

Run the deployment script:
```
forge script script/DeployVaults.s.sol --rpc-url http://localhost:8545 --broadcast
```

This will:
- Deploy the V1 implementation
- Deploy the beacon pointing to the V1 implementation
- Deploy the factory contract
- Create 3 vault instances

Save the addresses for future use, especially the beacon address.

### 2. Upgrade to V2

Set the environment variables:
```
PRIVATE_KEY=your_private_key_here
BEACON_ADDRESS=your_beacon_address_here
```

Run the upgrade script:
```
forge script script/UpgradeToV2.s.sol --rpc-url http://localhost:8545 --broadcast
```

This will:
- Deploy the V2 implementation
- Upgrade the beacon to point to the V2 implementation
- All proxies will automatically use the new implementation

### 3. Rollback (if needed)

Set the environment variables:
```
PRIVATE_KEY=your_private_key_here
BEACON_ADDRESS=your_beacon_address_here
VERSION_INDEX=0  # 0 for V1, 1 for V2, etc.
```

Run the rollback script:
```
forge script script/RollbackToVersion.s.sol --rpc-url http://localhost:8545 --broadcast
```

This will:
- Revert the beacon to point to the specified implementation version
- All proxies will automatically use the specified implementation

## Testing

Run the tests:
```
forge test -v
```

The tests verify:
- Initial deployment functionality
- Upgrade to V2 functionality
- Rollback functionality
- Multiple versions management
- That all vaults are upgraded together

## Security Considerations

- Only the beacon owner can upgrade or rollback implementations
- All contracts use OpenZeppelin's standard libraries for security
- Critical operations are protected by access control measures

## Local tests

### Init logs (v1)
- VaultImplementationV1 deployed at: 0x5FbDB2315678afecb367f032d93F642f64180aa3
- VersionControlBeacon deployed at: 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
- VaultFactory deployed at: 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
- Vault for Token1 deployed at: 0x75537828f2ce51be7289709686A69CbFDbB714F1
- Vault for Token2 deployed at: 0xE451980132E65465d0a498c53f0b5227326Dd73F
- Vault for Token3 deployed at: 0x5392A33F7F677f59e833FEBF4016cDDD88fF9E67

### Check, send, check to Token1
- cast call 0x75537828f2ce51be7289709686A69CbFDbB714F1 "getBalance() returns (uint256)" --rpc-url http://localhost:8545
- cast send 0x75537828f2ce51be7289709686A69CbFDbB714F1 "deposit(uint256)" 100 --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY
- cast call 0x75537828f2ce51be7289709686A69CbFDbB714F1 "getBalance() returns (uint256)" --rpc-url http://localhost:8545

### Migrate to V2 logs
- VaultImplementationV2 deployed at: 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853
- Current implementation: 0x5FbDB2315678afecb367f032d93F642f64180aa3
- Beacon upgraded to V2 implementation
- New implementation: 0xa513E6E4b8f2a923D98304ec87F64353C4D5C853

### Check Token1
- cast call 0x75537828f2ce51be7289709686A69CbFDbB714F1 "getBalance() returns (uint256)" --rpc-url http://localhost:8545

### Check withdraw and balance
- cast send 0x75537828f2ce51be7289709686A69CbFDbB714F1 "withdraw(uint256 amount)" 42 --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY
- cast call 0x75537828f2ce51be7289709686A69CbFDbB714F1 "getBalance() returns (uint256)" --rpc-url http://localhost:8545

### Move to versions
- cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "implementation() returns (address)" --rpc-url http://localhost:8545
- cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getVersionCount() returns (uint256)" --rpc-url http://localhost:8545
- forge script script/RollbackToVersion.s.sol --rpc-url http://localhost:8545 --broadcast
- cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "implementation() returns (address)" --rpc-url http://localhost:8545
- next should fail:
- cast send 0x75537828f2ce51be7289709686A69CbFDbB714F1 "withdraw(uint256 amount)" 42 --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY
- set VERSION_INDEX to 1
- forge script script/RollbackToVersion.s.sol --rpc-url http://localhost:8545 --broadcast
- cast send 0x75537828f2ce51be7289709686A69CbFDbB714F1 "withdraw(uint256 amount)" 42 --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY
- cast call 0x75537828f2ce51be7289709686A69CbFDbB714F1 "getBalance() returns (uint256)" --rpc-url http://localhost:8545