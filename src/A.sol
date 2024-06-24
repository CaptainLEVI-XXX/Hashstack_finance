// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.2;

import {Initializable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "lib/openzeppelin-contracts-upgradeable/contracts/utils/ReentrancyGuardUpgradeable.sol";


contract A is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable{
    bytes32 constant _varSlot =
        0x05e7d7db1903cbaf021c831e376dd114f3916ea01bd733ec6aae29fa451650c4;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
    }

    function setter(uint256 newNumber) external onlyOwner() nonReentrant{
        assembly {
            let x := sload(_varSlot)
            let s := add(x, newNumber)
            if lt(s, x) {
                revert(0, 0)
            }
            sstore(_varSlot, s)
        }
    }

    function getter() external view returns (uint256 value) {
        assembly {
            value := sload(_varSlot)
        }
    }

    /*
    Override function
    */
    function _authorizeUpgrade(address newImplementation) internal virtual override {

    }

    function upgradeTo(address newImplementation, bytes memory data) public {
        upgradeToAndCall(newImplementation, data);
}
}
