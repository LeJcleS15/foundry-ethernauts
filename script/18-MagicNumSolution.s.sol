// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {MagicNum} from "../src/18-MagicNum.sol";
import {MagicNumFactory} from "../src/MagicNumFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract MagicNumSolution is Script {
    MagicNum public magicNumLevel;
    address payable instanceAddress = payable(0x571A025a58B9c3a8fBa7F4846c418498E4049136);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        magicNumLevel = MagicNum(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // Bytecode for a contract that returns 42
        bytes memory bytecode = hex"69602a60005260206000f3600052600a6016f3";
        address solver;
        assembly {
            solver := create(0, add(bytecode, 0x20), mload(bytecode))
        }

        require(solver != address(0), "Failed to deploy solver");

        magicNumLevel.setSolver(solver);

        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new MagicNumFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}
