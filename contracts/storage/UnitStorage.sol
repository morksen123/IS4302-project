// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./base/DataStorageBase.sol";
import "../types/DataTypes.sol";

contract UnitStorage is DataStorageBase {
    // Storage
    mapping(address => DataTypes.Unit) private units;
    mapping(address => uint256) private managementFeePayments;
    mapping(address => uint256) private lastPaymentDates;

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

    // Setters
    function setUnit(address unitAddress, DataTypes.Unit calldata unit) external onlyAuthorized {
        units[unitAddress] = unit;
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
}