// voting system
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";

contract VotingSystem is IVotingSystem {
    struct Proposal {
        bytes32 name;
        uint voteCount;
    }

    IUnitManager private unitManager;
    Proposal[] private proposals;
    bool public votingActive;
    uint256 public lastVotingYear;

    constructor(address unitManagerAddress) public {
        unitManager = IUnitManager(unitManagerAddress);
    }

    function startVotingSession(bytes32[] calldata proposalNames) external override {
        require(!votingActive, "Voting session already active");
        // TODO init proposals from TicketSystem
        emit VotingSessionStarted(block.timestamp, proposalNames);
    }

    function endVotingSession() external override {
        require(votingActive, "No active voting session");
        votingActive = false;
        emit VotingSessionEnded(block.timestamp);
    }

    function grantVotingRights(address unitAddress) external override {
        unitManager.updateVotingRights(unitAddress, true);
        emit VotingRightsGranted(unitAddress);
    }

    function revokeVotingRights(address unitAddress) external override {
        unitManager.updateVotingRights(unitAddress, false);
        emit VotingRightsRevoked(unitAddress);
    }

    function vote(uint proposalIndex) external override {
        require(votingActive, "No active voting session");
        require(unitManager.hasVotingRights(msg.sender), "No voting rights");
        proposals[proposalIndex].voteCount += 1;
        emit VoteCast(msg.sender, proposalIndex);
    }

    function getWinnerName() external view override returns (bytes32) {
        require(!votingActive, "Voting session still active");
        // ... (calculate and return winner name) 
        //TODO decide which are approved, rejected, onhold. within budget, minVotesRequired etc
        //TODO modify to return list of approved proposals within budget
    }

    // Additional view functions for proposals
    function getProposalCount() external view override returns (uint256) {
        return proposals.length;
    }

    function getProposalName(uint proposalIndex) external view override returns (bytes32) {
        return proposals[proposalIndex].name;
    }

    function getVoteCount(uint proposalIndex) external view override returns (uint256) {
        return proposals[proposalIndex].voteCount;
    }
}