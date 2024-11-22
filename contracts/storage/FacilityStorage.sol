// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./base/DataStorageBase.sol";

contract FacilityStorage is DataStorageBase {
    struct Facility {
        string name;
        uint256 openTime;
        uint256 closeTime;
        bool active;
    }

    struct Booking {
        address user;
        uint256 date;
        uint256 startHour;
        uint256 duration;
    }

    // Storage
    mapping(uint256 => Facility) private facilities;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => bool))) private bookings;
    mapping(uint256 => mapping(uint256 => mapping(uint256 => Booking))) private bookingDetails;
    uint256 private facilityCount;

    // Getters
    function getFacility(uint256 _facilityId) external view onlyAuthorized returns (Facility memory) {
        return facilities[_facilityId];
    }

    function getBooking(uint256 _facilityId, uint256 _date, uint256 _hour) external view onlyAuthorized returns (Booking memory) {
        return bookingDetails[_facilityId][_date][_hour];
    }

    function isBooked(uint256 _facilityId, uint256 _date, uint256 _hour) external view onlyAuthorized returns (bool) {
        return bookings[_facilityId][_date][_hour];
    }

    function getFacilityCount() external view onlyAuthorized returns (uint256) {
        return facilityCount;
    }

    // Setters
    function addFacility(string memory _name, uint256 _openTime, uint256 _closeTime) external onlyAuthorized returns (uint256) {
        facilities[facilityCount] = Facility({
            name: _name,
            openTime: _openTime,
            closeTime: _closeTime,
            active: true
        });
        facilityCount++;
        return facilityCount - 1;
    }

    function setBooking(uint256 _facilityId, uint256 _date, uint256 _hour, Booking memory _booking) external onlyAuthorized {
        bookings[_facilityId][_date][_hour] = true;
        bookingDetails[_facilityId][_date][_hour] = _booking;
    }

    function removeBooking(uint256 _facilityId, uint256 _date, uint256 _hour) external onlyAuthorized {
        bookings[_facilityId][_date][_hour] = false;
        delete bookingDetails[_facilityId][_date][_hour];
    }
}