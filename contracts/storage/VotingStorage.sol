// storage
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "./base/DataStorageBase.sol";
import "../types/DataTypes.sol";

contract VotingStorage is DataStorageBase {
    // Storage for proposals
    mapping(uint256 => DataTypes.Proposal) private proposals; // Proposal ID -> Proposal data
    uint256 private proposalCount; // Counter for proposal IDs

    // Tracks if a unit has voted on a specific proposal
    mapping(uint256 => mapping(address => bool)) private hasVoted; // Proposal ID -> Voter address -> Voted status

    // Tracks if AGM has started
    bool private AGMStarted;

    // Getters
    function getProposal(
        uint256 proposalId
    ) external view onlyAuthorized returns (DataTypes.Proposal memory) {
        require(proposalId < proposalCount, "Invalid proposal ID");
        return proposals[proposalId];
    }

    function getProposalCount() external view onlyAuthorized returns (uint256) {
        return proposalCount;
    }

    function hasUnitVoted(
        uint256 proposalId,
        address unitAddress
    ) external view onlyAuthorized returns (bool) {
        return hasVoted[proposalId][unitAddress];
    }

    function isAGMStarted() external view onlyAuthorized returns (bool) {
        return AGMStarted;
    }

    // Setters
    function addProposal(DataTypes.Proposal calldata proposal) external onlyAuthorized {
        proposals[proposalCount] = proposal;
        proposalCount++;
    }

    function updateProposal(
        uint256 proposalId,
        DataTypes.Proposal calldata updatedProposal
    ) external onlyAuthorized {
        require(proposalId < proposalCount, "Invalid proposal ID");
        proposals[proposalId] = updatedProposal;
    }

    function recordVote(
        uint256 proposalId,
        address unitAddress
    ) external onlyAuthorized {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(!hasVoted[proposalId][unitAddress], "Unit already voted on this proposal");
        hasVoted[proposalId][unitAddress] = true;
    }

    function setAGMStatus(bool status) external onlyAuthorized {
        AGMStarted = status;
    }
}