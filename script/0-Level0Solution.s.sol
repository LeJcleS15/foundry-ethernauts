// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Level0} from "../src/0-Level0.sol";
import {Script, console} from "forge-std/Script.sol";

contract Level0Solution is Script {
    Level0 public level0 = Level0(0xb0937C6627a0387bfAA29ed3d243aD0d7587E35d);

    function run() external {
        string memory password = level0.password();
        console.log("Password for the level: %s", password);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        level0.authenticate(password);
        vm.stopBroadcast();
    }
}
