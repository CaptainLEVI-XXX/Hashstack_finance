// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/A.sol";
import "../src/AV2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AV2UpgradeTest is Test {
    A public implementationV1;
    AV2 public implementationV2;
    ERC1967Proxy public proxy;
    A public wrappedProxyV1;
    AV2 public wrappedProxyV2;

    address public owner = address(0x1);
    address public newAdmin = address(0x2);

    function setUp() public {
        // Deploy V1
        implementationV1 = new A();
        bytes memory dataV1 = abi.encodeWithSelector(A.initialize.selector, owner);
        proxy = new ERC1967Proxy(address(implementationV1), dataV1);
        wrappedProxyV1 = A(address(proxy));

        // Deploy V2
        implementationV2 = new AV2();
    }

    function testUpgradeAndFunctionality() public {
        // 1. Function call on V1
        // 1.1 Calling the getter function in contract A must return 0
        assertEq(wrappedProxyV1.getter(), 0, "Initial value should be 0");

        // 1.2 Call the setter function with an input of 10
        vm.prank(owner);
        wrappedProxyV1.setter(10);

        // 1.3 Now call the getter function. It must return the value 10
        assertEq(wrappedProxyV1.getter(), 10, "Value should be 10 after setter");

        // 2. Fetch the admin address of contract A
        address originalAdmin = wrappedProxyV1.owner();
        assertEq(originalAdmin, owner, "Original admin should be the owner");

        // 3. Upgrade contract A so that it inherits contract B
        vm.prank(owner);
        bytes memory dataV2 = abi.encodeWithSelector(AV2.init.selector, owner);
        wrappedProxyV1.upgradeTo(address(implementationV2),dataV2);
        wrappedProxyV2 = AV2(address(proxy));

    
        assertEq(wrappedProxyV2.isSuperAdmin(owner),true,"Not the super Admin");



        // 4. Change the admin address of contract A to some other address from the access registry
        vm.prank(owner);
        wrappedProxyV2.addAdmin(newAdmin);
        vm.prank(owner);
        wrappedProxyV2.transferSuperOwnership(newAdmin);

        // 5. Fetch the admin address of contract A. Should be different from the previous admin address
        assertTrue(wrappedProxyV2.isAdmin(newAdmin), "New admin should have admin role");
        assertFalse(wrappedProxyV2.isAdmin(owner), "Old admin should not have admin role");

        // 6. Function call on V2
        // 6.1 Calling the getter function must return 10
        assertEq(wrappedProxyV2.getter(), 10, "Value should still be 10 after upgrade");

        // 6.2 Call the setter function with an input of 81
        vm.prank(newAdmin);
        wrappedProxyV2.setter(81);

        // 7. Now, call the getter function, it must return 91
        assertEq(wrappedProxyV2.getter(), 91, "Final value should be 91");
    }
}