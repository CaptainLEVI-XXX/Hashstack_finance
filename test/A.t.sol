// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import "forge-std/Test.sol";
import "../src/A.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract ATest is Test {
    A public implementation;
    ERC1967Proxy public proxy;
    A public wrappedProxy;

    address public owner = address(0x1);
    address public user = address(0x2);

    function setUp() public {
        implementation = new A();
        bytes memory data = abi.encodeWithSelector(A.initialize.selector, owner);
        proxy = new ERC1967Proxy(address(implementation), data);

        wrappedProxy = A(address(proxy));

        vm.label(address(implementation), "Implementation");
        vm.label(address(proxy), "Proxy");
        vm.label(owner, "Owner");
        vm.label(user, "User");
    }

    function testInitialization() public {
        assertEq(wrappedProxy.owner(), owner);
    }

    function testSetterAndGetter() public {

        vm.startPrank(owner);


        uint256 initialValue = wrappedProxy.getter();
        assertEq(initialValue, 0);
        wrappedProxy.setter(10);
        assertEq(wrappedProxy.getter(), 10);
        wrappedProxy.setter(5);
        assertEq(wrappedProxy.getter(), 15);
    }

    function testSetterOverflow() public {

        vm.startPrank(owner);
        wrappedProxy.setter(type(uint256).max);
        vm.expectRevert();
        wrappedProxy.setter(1);
    }

    function testOwnership() public {
        vm.startPrank(owner);
        wrappedProxy.transferOwnership(user);
        assertEq(wrappedProxy.owner(), user);
    }

    function testUpgrade() public {

        vm.startPrank(owner);
        // Deploy a new implementation
        A newImplementation = new A();

        // Upgrade the proxy to the new implementation
        wrappedProxy.upgradeTo(address(newImplementation),bytes(""));

        // Verify that the state is preserved
        uint256 value = wrappedProxy.getter();
        wrappedProxy.setter(5);
        assertEq(wrappedProxy.getter(), value + 5);
    }
}