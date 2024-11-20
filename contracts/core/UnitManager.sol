// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IUnitManager.sol";
import "../storage/UnitStorage.sol";
import "../types/DataTypes.sol";
import "../oracles/MockPropertyOracle.sol";

/**
 * @title UnitManager
 * @notice Manages all unit-related operations in the Condo DAO
 * @dev Implements use cases 3.1 to 3.9 for unit management, fees, and facilities
 */
contract UnitManager is IUnitManager {
    // State Variables
    UnitStorage private unitStorage;
    MockPropertyOracle private propertyOracle;

    // Constants for fee calculations
    uint256 private constant MANAGEMENT_FEE = 0.1 ether; // Base fee: 0.1 ETH
    uint256 private constant LATE_FEE_PERCENTAGE = 5; // Late fee: 5%
    uint256 private constant PAYMENT_PERIOD = 30 days; // Grace period
    uint256 private constant AGM_DISCOUNT_PERCENTAGE = 5; // AGM discount: 5%

    constructor(address storageAddress, address oracleAddress) public {
        unitStorage = UnitStorage(storageAddress);
        propertyOracle = MockPropertyOracle(oracleAddress);
    }

    modifier onlyRegistered(address unitAddress) {
        require(isRegistered(unitAddress), "Unit not registered");
        _;
    }

    /**
     * @notice Registers a new unit with property ownership verification
     * @param unitAddress Address of the unit owner
     */
    function registerUnit(address unitAddress) external {
        require(!isRegistered(unitAddress), "Unit already registered");
        require(propertyOracle.verifyOwnership(unitAddress), "Not a verified property owner");

        DataTypes.Unit memory newUnit = DataTypes.Unit({
            registered: true,
            managementFee: MANAGEMENT_FEE,
            lateFees: 0,
            votingRights: true,
            bookingQuota: DataTypes.DEFAULT_BOOKING_QUOTA,
            lastPayment: block.timestamp,
            agmParticipation: false
        });
        unitStorage.setUnit(unitAddress, newUnit);
        emit UnitRegistered(unitAddress);
    }

    /**
     * @notice Calculates management fee with potential AGM discount
     * @param unitAddress Address of the unit
     * @return Fee amount in ETH
     */
    function calculateManagementFee(address unitAddress) public view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        if (unit.agmParticipation) {
            return (MANAGEMENT_FEE * (100 - AGM_DISCOUNT_PERCENTAGE)) / 100;
        }
        return MANAGEMENT_FEE;
    }

    /**
     * @notice Calculates late fees based on payment delay
     * @param unitAddress Address of the unit
     * @return Late fee amount in ETH
     */
    function calculateLateFees(address unitAddress) public view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        uint256 timeSincePayment = block.timestamp - unit.lastPayment;

        if (timeSincePayment <= PAYMENT_PERIOD) {
            return 0;
        }

        uint256 overduePeriods = (timeSincePayment - PAYMENT_PERIOD) / PAYMENT_PERIOD + 1;
        uint256 baseFee = calculateManagementFee(unitAddress);
        return (baseFee * LATE_FEE_PERCENTAGE * overduePeriods) / 100;
    }

    /**
     * @notice Processes management fee payment with late fees
     */
    function payManagementFee() external payable {
        DataTypes.Unit memory unit = unitStorage.getUnit(msg.sender);
        uint256 requiredFee = calculateManagementFee(msg.sender);
        uint256 lateFees = calculateLateFees(msg.sender);
        uint256 totalRequired = requiredFee + lateFees;

        require(msg.value >= totalRequired, "Insufficient payment for fees and late fees");

        unit.lateFees = 0;
        unit.lastPayment = block.timestamp;
        unitStorage.setUnit(msg.sender, unit);
        unitStorage.updatePaymentInfo(msg.sender, msg.value, block.timestamp);

        emit ManagementFeePaid(msg.sender, requiredFee);
        if (lateFees > 0) {
            emit LateFeePaid(msg.sender, lateFees);
        }
    }

    /**
     * @notice Updates voting rights status for a unit
     * @param unitAddress Address of the unit
     * @param status New voting rights status
     */
    function updateVotingRights(
        address unitAddress,
        bool status
    ) external onlyRegistered(unitAddress) {
        unitStorage.updateVotingRights(unitAddress, status);
        emit VotingRightsUpdated(unitAddress, status);
    }

    /**
     * @notice Updates facility booking quota
     * @param unitAddress Address of the unit
     * @param change Amount to change
     * @param increase True to increase, false to decrease
     */
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

    /**
     * @notice Resets booking quota to default value
     */
    function resetBookingQuota(address unitAddress) external onlyRegistered(unitAddress) {
        unitStorage.updateBookingQuota(unitAddress, DataTypes.DEFAULT_BOOKING_QUOTA);
        emit BookingQuotaUpdated(unitAddress, DataTypes.DEFAULT_BOOKING_QUOTA);
    }

    // === AGM PARTICIPATION MANAGEMENT ===
    function recordAGMParticipation(
        address unitAddress,
        bool participated
    ) external onlyRegistered(unitAddress) {
        unitStorage.updateAGMParticipation(unitAddress, participated);
        emit AGMParticipationRecorded(unitAddress, participated);
    }

    // === VIEW FUNCTIONS ===
    function isRegistered(address unitAddress) public view returns (bool) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.registered;
    }

    function getManagementFee(address unitAddress) external view returns (uint256) {
        return calculateManagementFee(unitAddress);
    }

    function getLateFee(address unitAddress) external view override returns (uint256) {
        return calculateLateFees(unitAddress);
    }

    function hasVotingRights(address unitAddress) external view returns (bool) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.votingRights;
    }

    function getBookingQuota(address unitAddress) external view returns (uint256) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.bookingQuota;
    }

    function getAGMParticipation(address unitAddress) external view returns (bool) {
        DataTypes.Unit memory unit = unitStorage.getUnit(unitAddress);
        return unit.agmParticipation;
    }

    // === HELPER FUNCTIONS ===
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
