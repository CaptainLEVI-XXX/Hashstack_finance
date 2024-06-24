// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/AccessControlUpgradeable.sol";

contract AccessRegistry is AccessControlUpgradeable {
    bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    bytes32 constant _initializedSlot =
        0x4e5f991bca30eca2d4643aaefa807e88f96a4a97398933d572a3c0d973004a01;

    function init(address initialSuperAdmin) public virtual{
        require(!_initialized(), "AccessRegistry: already initialized");
        _setInitialized();
        _grantRole(SUPER_ADMIN_ROLE, initialSuperAdmin);
        _setRoleAdmin(ADMIN_ROLE, SUPER_ADMIN_ROLE);
        _setRoleAdmin(SUPER_ADMIN_ROLE, SUPER_ADMIN_ROLE);
    }

    function _initialized() internal view returns (bool flag) {
        assembly {
            flag := sload(_initializedSlot)
        }
    }

    function _setInitialized() internal {
        assembly {
            sstore(
                _initializedSlot,
                0x0000000000000000000000000000000000000000000000000000000000000001
            )
        }
    }

    function addAdmin(address newAdmin) public onlyRole(SUPER_ADMIN_ROLE) {
        grantRole(ADMIN_ROLE, newAdmin);
    }

    function removeAdmin(address admin) public onlyRole(SUPER_ADMIN_ROLE) {
        revokeRole(ADMIN_ROLE, admin);
    }

    function transferAdminRole(
        address currentAdmin,
        address newAdmin
    ) public onlyRole(SUPER_ADMIN_ROLE) {
        require(
            hasRole(ADMIN_ROLE, currentAdmin),
            "Current admin does not have the ADMIN_ROLE"
        );
        revokeRole(ADMIN_ROLE, currentAdmin);
        grantRole(ADMIN_ROLE, newAdmin);
    }

    function renounceAdminRole() public {
        renounceRole(ADMIN_ROLE, msg.sender);
    }

    function isSuperAdmin(address account) public view returns (bool) {
        return hasRole(SUPER_ADMIN_ROLE, account);
    }

    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }

    function transferSUperAdminOwnerShip(){}
}
