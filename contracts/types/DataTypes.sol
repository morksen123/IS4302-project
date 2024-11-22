// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

library DataTypes {
    // Constants need to be declared at the library level
    enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum FeedbackStatus { Open, Resolved }


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


    struct Proposal {
        address unitAddress;
        string title;
        string description;
        string proposedSolution;
        uint256 suggestedBudget;
        ProposalStatus status;
        uint256[] voteIds;
        uint256 createdAt;
        uint256 votesFor; 
        uint256 votesAgainst;
        uint256 votesAbstained;
        uint256 totalVotes;
    }

    struct Feedback {
        address unitAddress;
        string feedbackText;
       //  FeedbackStatus status;
        uint256 createdAt;
    }
    uint256 constant DEFAULT_BOOKING_QUOTA = 5;
}
