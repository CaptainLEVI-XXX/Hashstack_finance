// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {A} from "./A.sol";
import {AccessRegistry} from "./AccessRegistry.sol";


contract AV2 is A, AccessRegistry {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function init(address initialSuperAdmin) public virtual override{
        AccessRegistry.init(initialSuperAdmin);
    }

    function transferSuperOwnership(address newSuperAdmin) public onlyRole(SUPER_ADMIN_ROLE) {
        transferOwnership(newSuperAdmin);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(SUPER_ADMIN_ROLE) {}
}