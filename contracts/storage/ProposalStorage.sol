

// contract ProposalStorage is DataStorageBase {
//     DataTypes.Proposal[] private proposals;

//     // Store a new proposal and return its ID
//      function storeProposal(DataTypes.Proposal memory proposal) external onlyAuthorized returns (uint256) {
//         proposals.push(proposal);
//         return proposals.length - 1; // Return the ID of the newly stored proposal
//     }

//     // Retrieve a proposal by its ID
//   function getProposal(uint256 proposalId) external view onlyAuthorized returns (DataTypes.Proposal memory) {
//         require(proposalId < proposals.length, "Invalid proposal ID");
//         return proposals[proposalId];
//     }

//     // Update the status of a proposal by its ID
//     function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external onlyAuthorized {
//         require(proposalId < proposals.length, "Invalid proposal ID");
//         proposals[proposalId].status = newStatus;
//     }

//     // Get the total count of proposals
//     function getProposalCount() external view returns (uint256) {
//         return proposals.length;
//     }
// }


// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./base/DataStorageBase.sol";
import "../types/DataTypes.sol";

contract ProposalStorage is DataStorageBase {
    DataTypes.Proposal[] private proposals; // Array to store all proposals
    mapping(uint256 => uint256[]) private proposalVoteIds; // Mapping of proposal ID to its associated vote IDs

    /// @notice Store a new proposal and return its ID
    /// @param proposal The proposal to store
    /// @return proposalId The ID of the newly stored proposal
    function storeProposal(DataTypes.Proposal memory proposal) external onlyAuthorized returns (uint256) {
        proposals.push(proposal);
        return proposals.length - 1; // Return the ID of the newly stored proposal
    }

    /// @notice Retrieve a proposal by its ID
    /// @param proposalId The ID of the proposal to retrieve
    /// @return The proposal data
    function getProposal(uint256 proposalId) external view onlyAuthorized returns (DataTypes.Proposal memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId];
    }

    /// @notice Update the status of a proposal by its ID
    /// @param proposalId The ID of the proposal to update
    /// @param newStatus The new status to set for the proposal
    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposals[proposalId].status = newStatus;
    }

    /// @notice Increment the vote counts for a proposal
    /// @param proposalId The ID of the proposal to update
    /// @param votesFor The number of "for" votes to add
    /// @param votesAgainst The number of "against" votes to add
    /// @param votesAbstained The number of "abstain" votes to add
    function incrementVotes(
        uint256 proposalId,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 votesAbstained
    ) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposals[proposalId].votesFor += votesFor;
        proposals[proposalId].votesAgainst += votesAgainst;
        proposals[proposalId].votesAbstained += votesAbstained;
    }

    /// @notice Store a vote ID for a proposal
    /// @param proposalId The ID of the proposal to associate the vote with
    /// @param voteId The ID of the vote to store
    function addVoteToProposal(uint256 proposalId, uint256 voteId) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposalVoteIds[proposalId].push(voteId);
    }

    /// @notice Get all vote IDs associated with a proposal
    /// @param proposalId The ID of the proposal to query
    /// @return An array of vote IDs
    function getVoteIdsForProposal(uint256 proposalId) external view onlyAuthorized returns (uint256[] memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposalVoteIds[proposalId];
    }

    /// @notice Retrieve all proposals
    /// @return An array of all proposals
    function getAllProposals() external view onlyAuthorized returns (DataTypes.Proposal[] memory) {
        return proposals;
    }

    /// @notice Retrieve proposals by their proposer (unit address)
    /// @param unitAddress The address of the proposer
    /// @return An array of proposals created by the given address
    function getProposalsByUnit(address unitAddress) external view onlyAuthorized returns (DataTypes.Proposal[] memory) {
        uint256 proposalCount = proposals.length;
        uint256 count = 0;

        // First, determine how many proposals match the unitAddress
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].unitAddress == unitAddress) {
                count++;
            }
        }

        // Create an array to store the matching proposals
        DataTypes.Proposal[] memory result = new DataTypes.Proposal[](count);
        uint256 index = 0;

        // Populate the result array
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].unitAddress == unitAddress) {
                result[index] = proposals[i];
                index++;
            }
        }

        return result;
    }

    /// @notice Retrieve proposals by status
    /// @param status The status to filter proposals by
    /// @return An array of proposals matching the given status
    function getProposalByStatus(DataTypes.ProposalStatus status) external view onlyAuthorized returns (DataTypes.Proposal[] memory) {
        uint256 proposalCount = proposals.length;
        uint256 count = 0;

        // First, determine how many proposals match the status
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].status == status) {
                count++;
            }
        }

        // Create an array to store the matching proposals
        DataTypes.Proposal[] memory result = new DataTypes.Proposal[](count);
        uint256 index = 0;

        // Populate the result array
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposals[i].status == status) {
                result[index] = proposals[i];
                index++;
            }
        }

        return result;
    }

    /// @notice Get the total count of proposals
    /// @return The total number of proposals
    function getProposalCount() external view onlyAuthorized returns (uint256) {
        return proposals.length;
    }
}

