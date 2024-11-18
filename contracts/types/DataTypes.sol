// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

library DataTypes {
    // Constants need to be declared at the library level
    uint256 public constant DEFAULT_BOOKING_QUOTA = 10;

    // Unit-related types
    struct Unit {
        bool registered;
        uint256 managementFee;
        uint256 lateFees;
        bool votingRights;
        uint256 bookingQuota;
        uint256 lastPayment;
    }

    // Proposal related types
    enum ProposalStatus {
        Submitted,
        Pending,
        Rejected,
        Approved,
        WorkInProgress,
        Completed,
        Closed
    }

    struct Proposal {
        address proposer;
        string title;
        string objectives;
        string background;
        string implementationPlan;
        string budget;
        uint256 dateCreated;
        uint256 votesFor;
        uint256 votesAgainst;
        ProposalStatus status;
    }
}
