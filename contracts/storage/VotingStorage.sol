// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./base/DataStorageBase.sol";

contract VotingStorage is DataStorageBase {

    // Enum Definitions
    enum VoteOption { None, For, Against, Abstain }
    enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum VoteStatus { None, Committed, Revealed }

    // Struct Definitions
    struct Proposal {
        address proposer;
        string title;
        string description;
        string solution;
        uint256 budget;
        ProposalStatus status;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstained;
        uint256 totalVotes;
    }

    struct Commit {
        VoteOption choice;
        bytes32 secret;    // Hash for verification
        VoteStatus status; // Status of the vote (None, Committed, Revealed)
    }

    // State Variables
    Proposal[] public proposals;
    mapping(address => mapping(uint256 => Commit)) public userCommits; // voter => (proposalId => Commit)

    // Getter Functions
    function getProposer(uint256 proposalId) public view returns (address) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId].proposer;
    }
}
