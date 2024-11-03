// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;


import "./base/DataStorageBase.sol";
import "../types/DataTypes.sol";

contract ProposalStorage is DataStorageBase {
    DataTypes.Proposal[] private proposals;

    // Store a new proposal and return its ID
     function storeProposal(DataTypes.Proposal memory proposal) external onlyAuthorized returns (uint256) {
        proposals.push(proposal);
        return proposals.length - 1; // Return the ID of the newly stored proposal
    }

    // Retrieve a proposal by its ID
  function getProposal(uint256 proposalId) external view onlyAuthorized returns (DataTypes.Proposal memory) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        return proposals[proposalId];
    }

    // Update the status of a proposal by its ID
    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external onlyAuthorized {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposals[proposalId].status = newStatus;
    }

    // Get the total count of proposals
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }
}
