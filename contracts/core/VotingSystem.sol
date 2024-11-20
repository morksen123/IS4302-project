// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";

contract VotingSystem {
    enum VoteOption { None, For, Against, Abstain }
    enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum VoteStatus { None, Committed, Revealed }

    struct Proposal {
        address proposer;
        string title;
        string description;
        string solution;
        uint256 budget;
        ProposalStatus status;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstained;
        uint256 totalVotes;
    }

    struct Commit {
        VoteOption choice;
        bytes32 secret;    // Hash for verification
        VoteStatus status; // Status of the vote (None, Committed, Revealed)
    }

    Proposal[] public proposals;
    mapping(address => mapping(uint256 => Commit)) public userCommits; // voter => (proposalId => Commit)
    IUnitManager public unitManager;

    event ProposalCreated(uint256 proposalId, address indexed proposer, string title);
    event VoteCommitted(uint256 proposalId, address indexed voter, bytes32 commitHash);
    event VoteRevealed(uint256 proposalId, address indexed voter, VoteOption choice);
    event VotingStarted(uint256 proposalId);
    event VotingClosed(uint256 proposalId, ProposalStatus result);

    modifier onlyProposer(uint256 proposalId) {
        require(msg.sender == proposals[proposalId].proposer, "Only the proposer can perform this action");
        _;
    }

    constructor(address _unitManager) public {
        unitManager = IUnitManager(_unitManager); // Set the UnitManager reference
    }

    function createProposal(
        string memory _title,
        string memory _description,
        string memory _solution,
        uint256 _budget
    ) public {
        Proposal memory newProposal = Proposal({
            proposer: msg.sender,
            title: _title,
            description: _description,
            solution: _solution,
            budget: _budget,
            status: ProposalStatus.Submitted,
            votesFor: 0,
            votesAgainst: 0,
            votesAbstained: 0,
            totalVotes: 0
        });

        proposals.push(newProposal);
        emit ProposalCreated(proposals.length - 1, msg.sender, _title);
    }

    function startVoting(uint256 proposalId) public onlyProposer(proposalId) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        proposals[proposalId].status = ProposalStatus.VotingOpen;
        emit VotingStarted(proposalId);
    }

    function commitVote(uint256 proposalId, bytes32 commitHash) public {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(proposals[proposalId].status == ProposalStatus.VotingOpen, "Voting is not open");
        require(userCommits[msg.sender][proposalId].status == VoteStatus.None, "Already committed a vote");
        require(unitManager.isRegistered(msg.sender), "Unit not registered");
        require(unitManager.hasVotingRights(msg.sender), "Unit does not have voting rights");

        userCommits[msg.sender][proposalId] = Commit({
            choice: VoteOption.None,
            secret: commitHash,
            status: VoteStatus.Committed
        });

        emit VoteCommitted(proposalId, msg.sender, commitHash);
    }

    function revealVote(uint256 proposalId, VoteOption choice, string memory secret) public {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(proposals[proposalId].status == ProposalStatus.VotingOpen, "Voting is not open");

        Commit storage userCommit = userCommits[msg.sender][proposalId];
        require(userCommit.status == VoteStatus.Committed, "No vote committed or already revealed");
        require(keccak256(abi.encodePacked(uint256(choice), secret)) == userCommit.secret, "Hash mismatch");

        userCommit.choice = choice;
        userCommit.status = VoteStatus.Revealed;

        Proposal storage proposal = proposals[proposalId];
        proposal.totalVotes++;

        if (choice == VoteOption.For) proposal.votesFor++;
        if (choice == VoteOption.Against) proposal.votesAgainst++;
        if (choice == VoteOption.Abstain) proposal.votesAbstained++;

        emit VoteRevealed(proposalId, msg.sender, choice);
    }

    function closeVoting(uint256 proposalId) public onlyProposer(proposalId) {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(proposals[proposalId].status == ProposalStatus.VotingOpen, "Voting is not open");

        Proposal storage proposal = proposals[proposalId];
        proposal.status = ProposalStatus.VotingClosed;

        // if (proposal.votesFor > proposal.votesAgainst) {
        //     proposal.status = ProposalStatus.Accepted;
        // } else {
        //     proposal.status = ProposalStatus.Rejected;
        // }

        emit VotingClosed(proposalId, proposal.status);
    }
}
