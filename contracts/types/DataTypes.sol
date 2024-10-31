// library DataTypes {
//     // Ticket-related types
//     enum TicketStatus {
//         Created,
//         UnderReview,
//         Rejected,
//         OpenForVoting,
//         Approved,
//         InProgress,
//         Completed,
//         Closed
//     }

//     struct Ticket {
//         uint256 id;
//         address creator;
//         string description;
//         uint256 budget;
//         TicketStatus status;
//         uint256 createdAt;
//         uint256 votingDeadline;
//         bool isProposal;       // true if proposal, false if feedback/complaint
//     }

//     // Unit-related types
//     struct Unit {
//         bool registered;
//         uint256 managementFee;
//         uint256 lateFees;
//         bool votingRights;
//         uint256 bookingQuota;
//         uint256 lastPayment;
//     }

//     // Voting-related types
//     enum VoteChoice {
//         For,
//         Against,
//         Abstain
//     }

//     struct Vote {
//         bool hasVoted;
//         VoteChoice choice;
//         uint256 timestamp;
//     }

//     struct VotingSession {
//         uint256 startTime;
//         uint256 endTime;
//         uint256 forVotes;
//         uint256 againstVotes;
//         uint256 abstainVotes;
//         uint256 quorum;
//         bool executed;
//     }

//     // Facility-related types
//     struct Facility {
//         uint256 id;
//         string name;
//         uint256 maxBookingsPerMonth;
//         uint256 bookingDuration;     // in hours
//         bool active;
//     }

//     struct Booking {
//         uint256 facilityId;
//         address user;
//         uint256 startTime;
//         uint256 endTime;
//         bool cancelled;
//     }

//     // Treasury-related types
//     struct Payment {
//         uint256 id;
//         address from;
//         uint256 amount;
//         PaymentType paymentType;
//         uint256 timestamp;
//     }

//     enum PaymentType {
//         ManagementFee,
//         LateFee,
//         VendorPayment,
//         Refund
//     }

//     // Events (if any shared events are needed)
//     event TicketStatusChanged(
//         uint256 indexed ticketId,
//         TicketStatus oldStatus,
//         TicketStatus newStatus
//     );

//     event VotingSessionCreated(
//         uint256 indexed ticketId,
//         uint256 startTime,
//         uint256 endTime,
//         uint256 quorum
//     );

//     // Constants
//     uint256 constant MAX_VOTING_DURATION = 7 days;
//     uint256 constant MIN_VOTING_DURATION = 1 days;
//     uint256 constant LATE_FEE_PERCENTAGE = 5; // 5%
//     uint256 constant DEFAULT_BOOKING_QUOTA = 4; // 4 bookings per month
// }