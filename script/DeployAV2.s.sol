// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import {Script} from "forge-std/Script.sol";
import {AV2} from "../src/AV2.sol";
import "forge-std/console.sol";

contract DeployAV2 is Script {

    address public constant OWNER = 0x4741b6F3CE01C4ac1C387BC9754F31c1c93866F0;

    function run() external {
        // Start broadcast for actual deployment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        AV2 implementation = new AV2();

        vm.stopBroadcast();

        // Log the addresses
        console.log("Implementation addressV2:", address(implementation));
    }
}

////source .env && forge script script/DeployAV2.s.sol:DeployAV2 --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
