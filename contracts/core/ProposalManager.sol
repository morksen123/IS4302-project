// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;


import "../interfaces/IProposalManager.sol";
import "../storage/ProposalStorage.sol";
import "../types/DataTypes.sol";

contract ProposalManager is IProposalManager {
    ProposalStorage private proposalStorage;

    // Constructor accepts the address of ProposalStorage
    constructor(address _proposalStorage) public {
        proposalStorage = ProposalStorage(_proposalStorage);
    }

    function raiseProposal(
        string calldata title,
        string calldata description,
        uint256 suggestedBudget,
        string calldata proposedSolution
    ) external {
        DataTypes.Proposal memory newProposal = DataTypes.Proposal({
            unitAddress: msg.sender,
            title: title,
            description: description,
            suggestedBudget: suggestedBudget,
            proposedSolution: proposedSolution,
            status: DataTypes.ProposalStatus.Draft,
            createdAt: block.timestamp
        });
        
        uint256 proposalId = proposalStorage.storeProposal(newProposal);
        emit ProposalRaised(proposalId, msg.sender, title);
    }

    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external {
        proposalStorage.updateProposalStatus(proposalId, newStatus);
        emit ProposalStatusUpdated(proposalId, newStatus);
    }

    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory) {
        return proposalStorage.getProposal(proposalId);
    }

    // event ProposalRaised(uint256 indexed proposalId, address indexed unitAddress, string title);
    // event ProposalStatusUpdated(uint256 indexed proposalId, DataTypes.ProposalStatus newStatus);
}