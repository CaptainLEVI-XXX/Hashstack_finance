// script/Deploy.s.sol
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {Script} from "forge-std/Script.sol";
import {A} from "../src/A.sol";
import {ERC1967Proxy} from "lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract DeployProxy is Script {

    address public constant OWNER = 0x4741b6F3CE01C4ac1C387BC9754F31c1c93866F0;

    function run() external {
        // Start broadcast for actual deployment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the implementation contract
        A implementation = new A();

        // Encode the initializer data
        bytes memory data = abi.encodeWithSelector(A.initialize.selector,OWNER);

        // Deploy the proxy with the implementation address and initializer data
        ERC1967Proxy proxy = new ERC1967Proxy(address(implementation), data);

        vm.stopBroadcast();

        // Log the addresses
        console.log("Implementation address:", address(implementation));
        console.log("Proxy address:", address(proxy));
    }
}

////source .env && forge script script/DeployProxy.s.sol:DeployProxy --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv
