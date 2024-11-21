// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;


import "../interfaces/IProposalManager.sol";
import "../storage/ProposalStorage.sol";
import "../types/DataTypes.sol";

// contract ProposalManager is IProposalManager {
//     ProposalStorage private proposalStorage;

//     // Constructor accepts the address of ProposalStorage
//     constructor(address _proposalStorage) public {
//         proposalStorage = ProposalStorage(_proposalStorage);
//     }

//     function raiseProposal(
//         string calldata title,
//         string calldata description,
//         uint256 suggestedBudget,
//         string calldata proposedSolution
//     ) external {
//         DataTypes.Proposal memory newProposal = DataTypes.Proposal({
//             unitAddress: msg.sender,
//             title: title,
//             description: description,
//             suggestedBudget: suggestedBudget,
//             proposedSolution: proposedSolution,
//             status: DataTypes.ProposalStatus.Submitted,
//             createdAt: block.timestamp
//         });
        
//         uint256 proposalId = proposalStorage.storeProposal(newProposal);
//         emit ProposalRaised(proposalId, msg.sender, title);
//     }

//     function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external {
//         proposalStorage.updateProposalStatus(proposalId, newStatus);
//         emit ProposalStatusUpdated(proposalId, newStatus);
//     }

//     function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory) {
//         return proposalStorage.getProposal(proposalId);
//     }

// }


    contract ProposalManager is IProposalManager {
    ProposalStorage private proposalStorage;
    address private votingContract; // Address of the Voting contract

    // event ProposalRaised(uint256 indexed proposalId, address indexed unitAddress, string title);
    // event ProposalStatusUpdated(uint256 indexed proposalId, DataTypes.ProposalStatus newStatus);

    // Constructor accepts the address of ProposalStorage
    constructor(address _proposalStorage) {
        proposalStorage = ProposalStorage(_proposalStorage);
    }

    /// @notice Set the Voting contract address
    /// @param _votingContract The address of the voting contract
    function setVotingContract(address _votingContract) external {
        require(votingContract == address(0), "Voting contract already set");
        votingContract = _votingContract;
    }

    modifier onlyVotingContract() {
        require(msg.sender == votingContract, "Only Voting contract can call this function");
        _;
    }

    /// @notice Raise a new proposal
    function raiseProposal(
        string calldata title,
        string calldata description,
        uint256 suggestedBudget,
        string calldata proposedSolution
    ) external override {
        DataTypes.Proposal memory newProposal = DataTypes.Proposal({
            unitAddress: msg.sender,
            title: title,
            description: description,
            suggestedBudget: suggestedBudget,
            proposedSolution: proposedSolution,
            status: DataTypes.ProposalStatus.Submitted,
            createdAt: block.timestamp,
            votesFor: 0,
            votesAgainst: 0,
            votesAbstained: 0,
            voteIds: new uint256[](0)
             });

        uint256 proposalId = proposalStorage.storeProposal(newProposal);
        emit ProposalRaised(proposalId, msg.sender, title);
    }

    /// @notice Update the status of a proposal
    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external override {
        proposalStorage.updateProposalStatus(proposalId, newStatus);
        emit ProposalStatusUpdated(proposalId, newStatus);
    }

    /// @notice Get a specific proposal by ID
    function getProposal(uint256 proposalId) external view override returns (DataTypes.Proposal memory) {
        return proposalStorage.getProposal(proposalId);
    }

    /// @notice Retrieve all proposals
    function getAllProposals() external view override returns (DataTypes.Proposal[] memory) {
        return proposalStorage.getAllProposals();
    }

    /// @notice Retrieve proposals by proposer (unit address)
    function getProposalsByUnit(address unitAddress) external view override returns (DataTypes.Proposal[] memory) {
        return proposalStorage.getProposalsByUnit(unitAddress);
    }

    /// @notice Retrieve proposals by status
    function getProposalByStatus(DataTypes.ProposalStatus status)
        external
        view
        override
        returns (DataTypes.Proposal[] memory)
    {
        return proposalStorage.getProposalByStatus(status);
    }

    /// @notice Retrieve the vote count for "for" votes on a proposal
    function getVotesFor(uint256 proposalId) external view override returns (uint256) {
        DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        return proposal.votesFor;
    }

    /// @notice Retrieve the vote count for "against" votes on a proposal
    function getVotesAgainst(uint256 proposalId) external view override returns (uint256) {
        DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        return proposal.votesAgainst;
    }

    /// @notice Retrieve the vote count for abstained votes on a proposal
    function getVotesAbstained(uint256 proposalId) external view override returns (uint256) {
        DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        return proposal.votesAbstained;
    }

    /// @notice Increment the vote counts for a proposal
    /// @dev Only the Voting contract can call this function
    function incrementVotes(
        uint256 proposalId,
        uint256 votesFor,
        uint256 votesAgainst,
        uint256 votesAbstained
    ) external override onlyVotingContract {
        proposalStorage.incrementVotes(proposalId, votesFor, votesAgainst, votesAbstained);
    }

    /// @notice Retrieve all vote IDs associated with a proposal
    function getVoteIdsForProposal(uint256 proposalId) external view override returns (uint256[] memory) {
        return proposalStorage.getVoteIdsForProposal(proposalId);
    }
}



