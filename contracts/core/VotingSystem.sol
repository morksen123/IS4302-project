// voting system
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";
import "../core/UnitManager.sol";
import "../interfaces/IUnitManager.sol";

contract VotingSystem {
    struct Proposal {
        address proposer;
        string title;
        string objectives;
        string background;
        string implementationPlan;
        string budget;
        uint256 dateCreated; // Use a timestamp for the date created
        uint256 votesFor;
        uint256 votesAgainst;
        bool isActive; // To track if the proposal is active
    }

    Proposal[] public proposals; 
    IUnitManager public unitManager;
    // Mapping to track if a unit has voted on a specific proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    constructor(address _unitManager) public {
        unitManager = IUnitManager(_unitManager); // Set the UnitManager reference
    }

    // Events
    event ProposalCreated(uint256 proposalId, address indexed proposer, string title);
    event VoteCast(uint256 proposalId, address indexed voter, bool support);

    // Function to create a proposal
    function createProposal(
        address _proposer,
        string memory _title,
        string memory _objectives,
        string memory _background,
        string memory _implementationPlan,
        string memory _budget
    ) external {
        require(_proposer != address(0), "Invalid proposer address");
        require(unitManager.isRegistered(_proposer), "Unit is not registered");
        require(unitManager.hasVotingRights(_proposer), "Unit does not have voting rights");

        Proposal memory newProposal = Proposal({
            proposer: _proposer,
            title: _title,
            objectives: _objectives,
            background: _background,
            implementationPlan: _implementationPlan,
            budget: _budget,
            dateCreated: block.timestamp,
            votesFor: 0,
            votesAgainst: 0,
            isActive: true
        });

        proposals.push(newProposal); // Add the new proposal to the proposals array
        emit ProposalCreated(proposals.length - 1, _proposer, _title); // Emit event for proposal creation
    }

    // Function to cast a vote for a proposal
    function vote(uint256 proposalId, bool support) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(proposals[proposalId].isActive, "Proposal is not active");
        require(unitManager.isRegistered(msg.sender), "Unit is not registered");
        require(unitManager.hasVotingRights(msg.sender), "Unit does not have voting rights");
        require(!hasVoted[proposalId][msg.sender], "Unit already voted on this proposal");

        Proposal storage proposal = proposals[proposalId];

        if (support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++; 
        }
        hasVoted[proposalId][msg.sender] = true;
        emit VoteCast(proposalId, msg.sender, support); // Emit event for vote casting
    }

    // Function to get proposal details
    function getProposal(uint256 proposalId) external view returns (
        address proposer,
        string memory title,
        string memory objectives,
        string memory background,
        string memory implementationPlan,
        string memory budget,
        uint256 dateCreated,
        uint256 votesFor,
        uint256 votesAgainst,
        bool isActive
    ) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];

        return (
            proposal.proposer,
            proposal.title,
            proposal.objectives,
            proposal.background,
            proposal.implementationPlan,
            proposal.budget,
            proposal.dateCreated,
            proposal.votesFor,
            proposal.votesAgainst,
            proposal.isActive
        );
    }

    // Function to deactivate a proposal (e.g., after voting is complete)
    function deactivateProposal(uint256 proposalId) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];

        proposal.isActive = false; // Deactivate the proposal
    }
}