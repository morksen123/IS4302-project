// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IProposalManager.sol";
import "../storage/ProposalStorage.sol";
import "../types/DataTypes.sol";
import "../core/UnitManager.sol";
import "../core/VotingSystem.sol";


contract ProposalManager is IProposalManager {
    ProposalStorage private proposalStorage;
    UnitManager private unitManager;
    address private votingContract; // Address of the Voting contract

    event ProposalRaised(uint256 indexed proposalId, address indexed unitAddress, string title);
    event ProposalStatusUpdated(uint256 indexed proposalId, DataTypes.ProposalStatus newStatus);
    event VotingContractSet(address votingContract);

    // Constructor accepts the addresses of ProposalStorage and UnitManager
    constructor(address _proposalStorage, address _unitManager) {
        proposalStorage = ProposalStorage(_proposalStorage);
        unitManager = UnitManager(_unitManager);
    }

    /// @notice Modifier to ensure the caller is a registered unit
    modifier onlyRegistered() {
        require(unitManager.isRegistered(msg.sender), "Unit not registered");
        _;
    }

 /// @notice Combined modifier for access control
    modifier onlyRegisteredOrVotingContract() {
        if (msg.sender != votingContract) {
            require(unitManager.isRegistered(msg.sender), "Unit not registered or unauthorized");
        }
        _;
    }

     /// @notice Set the Voting contract address
    /// @param _votingContract The address of the voting contract
    function setVotingContract(address _votingContract) external {
        require(votingContract == address(0), "Voting contract already set");
        require(_votingContract != address(0), "Invalid voting contract address");
        votingContract = _votingContract;
        emit VotingContractSet(_votingContract);
    }

    modifier onlyVotingContract() {
        require(msg.sender == votingContract, "Only Voting contract can call this function");
        _;
    }

    /// @notice Raise a new proposal
    /// @param proposer The address of the proposer
    function raiseProposal(
        address proposer,
        string calldata title,
        string calldata description,
        uint256 suggestedBudget,
        string calldata proposedSolution
    ) external override onlyRegistered {
        // Ensure the proposer is registered
        require(unitManager.isRegistered(proposer), "Proposer must be a registered unit");

        DataTypes.Proposal memory newProposal = DataTypes.Proposal({
            unitAddress: proposer,
            title: title,
            description: description,
            suggestedBudget: suggestedBudget,
            proposedSolution: proposedSolution,
            status: DataTypes.ProposalStatus.Submitted,
            createdAt: block.timestamp,
            votesFor: 0,
            votesAgainst: 0,
            votesAbstained: 0,
            voteIds: new uint256[](0),
            totalVotes: 0
        });

        uint256 proposalId = proposalStorage.storeProposal(newProposal);
        emit ProposalRaised(proposalId, proposer, title);
    }

    /// @notice Update the status of a proposal
    /// @param proposalId The ID of the proposal
    function updateProposalStatus(uint256 proposalId, DataTypes.ProposalStatus newStatus) external override onlyRegisteredOrVotingContract {
        proposalStorage.updateProposalStatus(proposalId, newStatus);
        emit ProposalStatusUpdated(proposalId, newStatus);
    }

    /// @notice Get a specific proposal by ID
    function getProposal(uint256 proposalId) external view override onlyRegisteredOrVotingContract returns (DataTypes.Proposal memory) {
        return proposalStorage.getProposal(proposalId);
    }

    /// @notice Retrieve all proposals
    function getAllProposals() external view override onlyRegisteredOrVotingContract returns (DataTypes.Proposal[] memory) {
        return proposalStorage.getAllProposals();
    }

    /// @notice Retrieve proposals by proposer (unit address)
    function getProposalsByUnit(address unitAddress) external view override onlyRegistered returns (DataTypes.Proposal[] memory) {
        require(unitManager.isRegistered(unitAddress), "Unit not registered");
        return proposalStorage.getProposalsByUnit(unitAddress);
    }

    /// @notice Retrieve proposals by status
    function getProposalByStatus(DataTypes.ProposalStatus status)
        external
        view
        override
        onlyRegistered
        returns (DataTypes.Proposal[] memory)
    {
        return proposalStorage.getProposalByStatus(status);
    }

    /// @notice Retrieve the vote count for "for" votes on a proposal
    function getVotesFor(uint256 proposalId) external view override onlyRegistered returns (uint256) {
        DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        return proposal.votesFor;
    }

    /// @notice Retrieve the vote count for "against" votes on a proposal
    function getVotesAgainst(uint256 proposalId) external view override onlyRegistered returns (uint256) {
        DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        return proposal.votesAgainst;
    }

    /// @notice Retrieve the vote count for abstained votes on a proposal
    function getVotesAbstained(uint256 proposalId) external view override onlyRegistered returns (uint256) {
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
    function getVoteIdsForProposal(uint256 proposalId) external view override onlyRegistered returns (uint256[] memory) {
        return proposalStorage.getVoteIdsForProposal(proposalId);
    }

}


   




