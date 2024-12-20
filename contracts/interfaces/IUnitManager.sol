// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface IUnitManager {
    // Events
    event UnitRegistered(address indexed unitAddress);
    event ManagementFeePaid(address indexed unitAddress, uint256 amount);
    event LateFeePaid(address indexed unitAddress, uint256 amount);
    event VotingRightsUpdated(address indexed unitAddress, bool status);
    event BookingQuotaUpdated(address indexed unitAddress, uint256 newQuota);
    event AGMParticipationRecorded(address indexed unitAddress, bool participated);

    // View Functions
    function isRegistered(address unitAddress) external view returns (bool);
    function getManagementFee(address unitAddress) external view returns (uint256);
    function calculateManagementFee(address unitAddress) external view returns (uint256);
    function getLateFee(address unitAddress) external view returns (uint256);
    function hasVotingRights(address unitAddress) external view returns (bool);
    function getBookingQuota(address unitAddress) external view returns (uint256);
    function getAGMParticipation(address unitAddress) external view returns (bool);
    function getRegisteredUnits() external view returns (address[] memory);

    // State-Changing Functions
    function registerUnit(address unitAddress) external;
    function payManagementFee() external payable;
    function updateVotingRights(address unitAddress, bool status) external;
    function updateBookingQuota(address unitAddress, uint256 change, bool increase) external;
    function resetBookingQuota(address unitAddress) external;
    function recordAGMParticipation(address unitAddress, bool participated) external;
}
