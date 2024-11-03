// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface IFacilityManager {
    // Events
    event FacilityAdded(uint256 indexed facilityId, string name);
    event BookingMade(uint256 indexed facilityId, address indexed user, uint256 date, uint256 startHour, uint256 duration);
    event BookingCancelled(uint256 indexed facilityId, address indexed user, uint256 date, uint256 startHour);

    // View Functions
    function getFacility(uint256 _facilityId) external view returns (
        string memory name,
        uint256 openTime,
        uint256 closeTime,
        bool active
    );
    
    function getBookingDetails(uint256 _facilityId, uint256 _date, uint256 _hour) external view returns (
        address user,
        uint256 date,
        uint256 startHour,
        uint256 duration
    );
    
    function checkAvailability(uint256 _facilityId, uint256 _date, uint256 _startHour, uint256 _duration) external view returns (bool);

    // State-Changing Functions
    function addFacility(string memory _name, uint256 _openTime, uint256 _closeTime) external;
    function bookFacility(uint256 _facilityId, uint256 _date, uint256 _startHour, uint256 _duration) external;
    function cancelBooking(uint256 _facilityId, uint256 _date, uint256 _startHour) external;
}
