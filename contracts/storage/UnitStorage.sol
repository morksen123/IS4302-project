// SPDX-License-Identifier: MIT
// pragma experimental ABIEncoderV2;

pragma solidity >=0.5.0 <0.9.0;

import "./base/DataStorageBase.sol";
import "../types/DataTypes.sol";

contract UnitStorage is DataStorageBase {
    // Storage
    mapping(address => DataTypes.Unit) private units;
    mapping(address => uint256) private managementFeePayments;
    mapping(address => uint256) private lastPaymentDates;
    address[] private registeredUnitAddresses;

    // Getters
    function getUnit(
        address unitAddress
    ) external view onlyAuthorized returns (DataTypes.Unit memory) {
        return units[unitAddress];
    }

    function getLastPaymentDate(
        address unitAddress
    ) external view onlyAuthorized returns (uint256) {
        return lastPaymentDates[unitAddress];
    }

    function getRegisteredUnits() external view onlyAuthorized returns (address[] memory) {
        return registeredUnitAddresses;
    }

    // Setters
    function setUnit(address unitAddress, DataTypes.Unit calldata unit) external onlyAuthorized {
        bool wasRegistered = units[unitAddress].registered;
        units[unitAddress] = unit;
        
        if (!wasRegistered && unit.registered) {
            registeredUnitAddresses.push(unitAddress);
        }
    }

    function updatePaymentInfo(
        address unitAddress,
        uint256 amount,
        uint256 timestamp
    ) external onlyAuthorized {
        managementFeePayments[unitAddress] = amount;
        lastPaymentDates[unitAddress] = timestamp;
    }

    function updateVotingRights(address unitAddress, bool status) external onlyAuthorized {
        units[unitAddress].votingRights = status;
    }

    function updateBookingQuota(address unitAddress, uint256 newQuota) external onlyAuthorized {
        units[unitAddress].bookingQuota = newQuota;
    }

    function updateAGMParticipation(
        address unitAddress,
        bool participated
    ) external onlyAuthorized {
        units[unitAddress].agmParticipation = participated;
    }
}
