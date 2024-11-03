// SPDX-License-Identifier: MIT
// pragma experimental ABIEncoderV2;

pragma solidity >=0.5.0 <0.9.0;


import "../interfaces/IUnitManager.sol";
import "../storage/UnitStorage.sol";
import "../types/DataTypes.sol";

contract UnitManager is IUnitManager {
    UnitStorage private unitStorage;
    uint256 private constant MANAGEMENT_FEE = 100 ether; // Example: 100 ETH
    uint256 private constant LATE_FEE_PERCENTAGE = 5; // 5%
    uint256 private constant PAYMENT_PERIOD = 30 days;

    constructor(address storageAddress) public {
        unitStorage = UnitStorage(storageAddress);
    }

    modifier onlyRegistered(address unitAddress) {
        require(isRegistered(unitAddress), "Unit not registered");
        _;
    }

    // Implementation of Interface Functions
    function isRegistered(address unitAddress) public view returns (bool) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.registered;
    }

    function getManagementFee(address unitAddress) external view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.managementFee;
    }

    function getLateFee(address unitAddress) external view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.lateFees;
    }

    function hasVotingRights(address unitAddress) external view returns (bool) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.votingRights;
    }

    function getBookingQuota(address unitAddress) external view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.bookingQuota;
    }

    function registerUnit(address unitAddress) external {
        require(!isRegistered(unitAddress), "Unit already registered");
        DataTypes.Unit memory newUnit = DataTypes.Unit({
            registered: true,
            managementFee: MANAGEMENT_FEE,
            lateFees: 0,
            votingRights: true,
            bookingQuota: DataTypes.DEFAULT_BOOKING_QUOTA,
            lastPayment: block.timestamp
        });
        unitStorage.setUnit(unitAddress, newUnit);
        emit UnitRegistered(unitAddress);
    }

    function payManagementFee() external payable {
        DataTypes.Unit memory unit = unitStorage.getUnit(msg.sender);
        require(msg.value >= unit.managementFee, "Insufficient payment");
        unitStorage.updatePaymentInfo(msg.sender, msg.value, block.timestamp);
        emit ManagementFeePaid(msg.sender, msg.value);

        // If there were late fees and excess payment, pay them off
        if (unit.lateFees > 0 && msg.value > unit.managementFee) {
            uint256 excessPayment = msg.value - unit.managementFee;
            uint256 lateFeePayment = min(excessPayment, unit.lateFees);
            if (lateFeePayment > 0) {
                unit.lateFees -= lateFeePayment;
                unitStorage.setUnit(msg.sender, unit);
                emit LateFeePaid(msg.sender, lateFeePayment);
            }
        }
    }

    function payLateFee() external payable {
        DataTypes.Unit memory unit = unitStorage.getUnit(msg.sender);
        require(unit.lateFees > 0, "No late fees due");
        require(msg.value > 0, "Payment amount must be greater than 0");
        require(msg.value <= unit.lateFees, "Payment exceeds late fees due");

        unit.lateFees -= msg.value;
        unitStorage.setUnit(msg.sender, unit);
        emit LateFeePaid(msg.sender, msg.value);
    }

    function updateVotingRights(
        address unitAddress,
        bool status
    ) external onlyRegistered(unitAddress) {
        unitStorage.updateVotingRights(unitAddress, status);
        emit VotingRightsUpdated(unitAddress, status);
    }

    function updateBookingQuota(
        address unitAddress,
        uint256 change,
        bool increase
    ) external onlyRegistered(unitAddress) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        uint256 newQuota = increase
            ? unit.bookingQuota + change
            : unit.bookingQuota > change
                ? unit.bookingQuota - change
                : 0;
        unitStorage.updateBookingQuota(unitAddress, newQuota);
        emit BookingQuotaUpdated(unitAddress, newQuota);
    }

    function resetBookingQuota(address unitAddress) external onlyRegistered(unitAddress) {
        unitStorage.updateBookingQuota(unitAddress, DataTypes.DEFAULT_BOOKING_QUOTA);
        emit BookingQuotaUpdated(unitAddress, DataTypes.DEFAULT_BOOKING_QUOTA);
    }

    // Helper functions
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
