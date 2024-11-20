// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";

contract VotingStorage {
    enum VoteOption { None, For, Against, Abstain }
    enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum VoteStatus { None, Committed, Revealed }

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
        bytes32 secret;
        VoteStatus status;
    }

    // Storage variables
    Proposal[] public proposals;
    mapping(address => mapping(uint256 => Commit)) public userCommits;
    IUnitManager public unitManager;

    // Getter functions
    function getProposal(uint256 proposalId) public view returns (Proposal memory) {
        return proposals[proposalId];
    }

    function getProposalsLength() public view returns (uint256) {
        return proposals.length;
    }

    function getUserCommit(address user, uint256 proposalId) public view returns (Commit memory) {
        return userCommits[user][proposalId];
    }

    function getUnitManager() public view returns (IUnitManager) {
        return unitManager;
    }

    // Setter functions
    function setUnitManager(address _unitManager) public {
        unitManager = IUnitManager(_unitManager);
    }

    function pushProposal(Proposal memory proposal) public {
        proposals.push(proposal);
    }

    function updateProposal(uint256 proposalId, Proposal memory proposal) public {
        proposals[proposalId] = proposal;
    }

    function setUserCommit(address user, uint256 proposalId, Commit memory commit) public {
        userCommits[user][proposalId] = commit;
    }
}