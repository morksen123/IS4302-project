// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

library DataTypes {
    // Unit-related types
    struct Unit {
        bool registered;
        uint256 managementFee;
        uint256 lateFees;
        bool votingRights;
        uint256 bookingQuota;
        uint256 lastPayment;
        bool agmParticipation;
    }

    uint256 constant DEFAULT_BOOKING_QUOTA = 5;
}
