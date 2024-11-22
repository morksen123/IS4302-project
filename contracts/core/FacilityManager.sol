// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IFacilityManager.sol";
import "../storage/FacilityStorage.sol";
import "../interfaces/IUnitManager.sol";

contract FacilityManager is IFacilityManager {
    FacilityStorage private facilityStorage;
    IUnitManager private unitManager;

    constructor(address _facilityStorage, address _unitManager) {
        facilityStorage = FacilityStorage(_facilityStorage);
        unitManager = IUnitManager(_unitManager);
    }

    modifier onlyRegisteredUnit() {
        require(unitManager.isRegistered(msg.sender), "Not a registered unit");
        _;
    }

    function addFacility(string memory _name, uint256 _openTime, uint256 _closeTime) external override {
        require(_openTime < 24 && _closeTime <= 24, "Invalid hours");
        require(_openTime < _closeTime, "Invalid operation hours");

        uint256 newFacilityId = facilityStorage.addFacility(_name, _openTime, _closeTime);
        emit FacilityAdded(newFacilityId, _name);
    }

    function checkAvailability(
        uint256 _facilityId,
        uint256 _date,
        uint256 _startHour,
        uint256 _duration
    ) public view override returns (bool) {
        require(_facilityId < facilityStorage.getFacilityCount(), "Invalid facility");
        
        FacilityStorage.Facility memory facility = facilityStorage.getFacility(_facilityId);
        require(facility.active, "Facility not active");
        require(_startHour >= facility.openTime, "Before opening hours");
        require(_startHour + _duration <= facility.closeTime, "Beyond closing hours");

        // Check if any hour within the duration is already booked
        for (uint256 i = 0; i < _duration; i++) {
            if (facilityStorage.isBooked(_facilityId, _date, _startHour + i)) {
                return false;
            }
        }
        return true;
    }

    function bookFacility(
        uint256 _facilityId,
        uint256 _date,
        uint256 _startHour,
        uint256 _duration
    ) external override onlyRegisteredUnit {
        require(unitManager.getBookingQuota(msg.sender) >= _duration, "Insufficient booking quota");
        require(checkAvailability(_facilityId, _date, _startHour, _duration), "Slot not available");
        
        // Mark all hours within the duration as booked
        for (uint256 i = 0; i < _duration; i++) {
            FacilityStorage.Booking memory booking = FacilityStorage.Booking({
                user: msg.sender,
                date: _date,
                startHour: _startHour + i,
                duration: 1
            });
            facilityStorage.setBooking(_facilityId, _date, _startHour + i, booking);
        }

        unitManager.updateBookingQuota(msg.sender, _duration, false);
        emit BookingMade(_facilityId, msg.sender, _date, _startHour, _duration);
    }

    function cancelBooking(
        uint256 _facilityId,
        uint256 _date,
        uint256 _startHour
    ) external override {
        // Get the original booking to check duration
        FacilityStorage.Booking memory booking = facilityStorage.getBooking(_facilityId, _date, _startHour);
        require(booking.user == msg.sender, "Not your booking");
        
        uint256 duration = booking.duration;
        
        // Clear all hours for this booking
        for (uint256 i = 0; i < duration; i++) {
            facilityStorage.removeBooking(_facilityId, _date, _startHour + i);
        }

        // Restore booking quota
        unitManager.updateBookingQuota(msg.sender, duration, true);

        emit BookingCancelled(_facilityId, msg.sender, _date, _startHour);
    }

    function getFacility(uint256 _facilityId) external view returns (
        string memory name,
        uint256 openTime,
        uint256 closeTime,
        bool active
    ) {
        require(_facilityId < facilityStorage.getFacilityCount(), "Invalid facility");
        FacilityStorage.Facility memory facility = facilityStorage.getFacility(_facilityId);
        return (facility.name, facility.openTime, facility.closeTime, facility.active);
    }

    function getBookingDetails(
        uint256 _facilityId,
        uint256 _date,
        uint256 _hour
    ) external view returns (
        address user,
        uint256 date,
        uint256 startHour,
        uint256 duration
    ) {
        FacilityStorage.Booking memory booking = facilityStorage.getBooking(_facilityId, _date, _hour);
        return (booking.user, booking.date, booking.startHour, booking.duration);
    }
}