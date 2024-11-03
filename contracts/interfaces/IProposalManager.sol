// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../types/DataTypes.sol";
interface IProposalManager {
    event ProposalRaised(uint256 indexed proposalId, address indexed unitAddress, string title);
    event ProposalStatusUpdated(uint256 indexed proposalId, DataTypes.ProposalStatus newStatus);

    function raiseProposal(
        string calldata title,
        string calldata description,
        uint256 suggestedBudget,
        string calldata proposedSolution
    ) external;

    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external;

    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory);
}
