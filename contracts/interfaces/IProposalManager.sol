// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../types/DataTypes.sol";
interface IProposalManager {
    // event ProposalRaised(uint256 indexed proposalId, address indexed unitAddress, string title);
    // event ProposalStatusUpdated(uint256 indexed proposalId, DataTypes.ProposalStatus newStatus);

    function raiseProposal(
                address proposer,
        string calldata title,
        string calldata description,
        uint256 suggestedBudget,
        string calldata proposedSolution
    ) external;

    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external;

    function getProposalByStatus(DataTypes.ProposalStatus status) external view returns (DataTypes.Proposal[] memory);

    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory);

    function getProposalsByUnit(address unitAddress) external view returns (DataTypes.Proposal[] memory);


    function getAllProposals() external view returns (DataTypes.Proposal[] memory);

    function getVotesFor(uint256 proposalId) external view returns (uint256);
    
    function getVotesAgainst(uint256 proposalId) external view returns (uint256);

    function getVotesAbstained(uint256 proposalId) external view returns (uint256);

     function incrementVotes(
        uint256 proposalId,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 votesAbstained
    ) external;

    function setVotingContract(address votingContract) external;

    function getVoteIdsForProposal(uint256 proposalId) external view returns (uint256[] memory);

}
