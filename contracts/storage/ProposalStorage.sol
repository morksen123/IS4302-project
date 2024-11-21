

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

    function getProposal(uint256 proposalId) external view onlyAuthorized returns (DataTypes.Proposal memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId];
    }

    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposals[proposalId].status = newStatus;
    }

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
  
    function addVoteToProposal(uint256 proposalId, uint256 voteId) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposalVoteIds[proposalId].push(voteId);
    }

    function getVoteIdsForProposal(uint256 proposalId) external view onlyAuthorized returns (uint256[] memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposalVoteIds[proposalId];
    }

    function getAllProposals() external view onlyAuthorized returns (DataTypes.Proposal[] memory) {
        return proposals;
    }

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

    function getProposalCount() external view onlyAuthorized returns (uint256) {
        return proposals.length;
    }
}

