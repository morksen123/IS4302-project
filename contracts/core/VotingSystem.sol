// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";
import "../core/UnitManager.sol";
import "../interfaces/IUnitManager.sol";

contract VotingSystem {
    enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum VoteOption { For, Against, Abstain }

    struct Proposal {
        address unitAddress; // Proposer's address
        string title;
        string description;
        string proposedSolution;
        uint256 suggestedBudget;
        ProposalStatus status;
        uint256 createdAtDate;

        uint256 votesFor;
        uint256 votesAgainst;
        uint256 votesAbstained;

        uint256 totalVotes;
        uint256 votesForPercentage;
        uint256 votesAgainstPercentage;
    }

    struct Vote {
        bytes32 commitHash; // Hash of the vote
        VoteOption revealedVote; // Revealed vote after AGM closure
        bool revealed; // Whether the vote is revealed
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => Vote)) public votes; // Votes tied to proposal and voter
    bool public AGMStarted = false;
    IUnitManager public unitManager;


    event ProposalCreated(uint256 proposalId, address indexed proposer, string title);
    event VoteCommitted(uint256 proposalId, address indexed voter);
    event ProposalRevealed(uint256 proposalId, uint256 votesFor, uint256 votesAgainst, uint256 votesAbstained);

    constructor(address _unitManager) public {
        unitManager = IUnitManager(_unitManager); // Set the UnitManager reference
    }

    // Function to create a proposal
    function createProposal(
        address _proposer,
        string memory _title,
        string memory _description,
        string memory _proposedSolution,
        uint256 _suggestedBudget
        ) external {
        require(_proposer != address(0), "Invalid proposer address");
        require(unitManager.isRegistered(_proposer), "Unit is not registered");
        require(unitManager.hasVotingRights(_proposer), "Unit does not have voting rights");
        require(!AGMStarted, "Cannot add proposal whilst AGM is in session");

        Proposal memory newProposal = Proposal({
            unitAddress: _proposer,
            title: _title,
            description: _description,
            proposedSolution: _proposedSolution,
            suggestedBudget: _suggestedBudget,
            status: ProposalStatus.Submitted,
            createdAtDate: block.timestamp,

            votesFor: 0,
            votesAgainst: 0,
            votesAbstained: 0,

            totalVotes: 0,
            votesForPercentage: 0,
            votesAgainstPercentage: 0
        });

        proposals.push(newProposal); // Add the new proposal to the proposals array
        emit ProposalCreated(proposals.length - 1, _proposer, _title); // Emit event for proposal creation
    }

    // Function to start AGM voting
    function startAGMVoting() external {
        require(!AGMStarted, "AGM already started");
        AGMStarted = true;

        for (uint256 i = 0; i < proposals.length; i++) {
            if (proposals[i].status == ProposalStatus.Submitted) {
                proposals[i].status = ProposalStatus.VotingOpen;
            }
        }
    }

    // Function to commit a vote (commit phase)
    function commitVote(uint256 proposalId, bytes32 commitHash) external {
        require(proposalId < proposals.length, "Invalid proposal ID");
        require(AGMStarted, "AGM not in session");
        require(proposals[proposalId].status == ProposalStatus.VotingOpen, "Voting not open");
        require(votes[proposalId][msg.sender].commitHash == bytes32(0), "Already voted");
        require(unitManager.isRegistered(msg.sender), "Unit not registered");
        require(unitManager.hasVotingRights(msg.sender), "Unit does not have voting rights");


        votes[proposalId][msg.sender] = Vote({
            commitHash: commitHash,
            revealedVote: VoteOption.Abstain, // Placeholder
            revealed: false
        });

        emit VoteCommitted(proposalId, msg.sender);
    }

    // Function to close AGM and reveal all votes (reveal phase)
    function closeAGM(string[] calldata secrets) external {
        require(AGMStarted, "AGM not started");
        AGMStarted = false;

        for (uint256 i = 0; i < proposals.length; i++) {
            Proposal storage proposal = proposals[i];
            if (proposal.status == ProposalStatus.VotingOpen) {
                proposal.status = ProposalStatus.VotingClosed;

                // Reveal votes
                address[] memory voters = getVotersForProposal(i);
                for (uint256 j = 0; j < voters.length; j++) {
                    address voter = voters[j];
                    Vote storage vote = votes[i][voter];

                    // Check if already revealed
                    if (vote.revealed) continue;

                    // Recreate hash and verify
                    bytes32 calculatedHash = keccak256(abi.encodePacked(secrets[j], voter));
                    require(vote.commitHash == calculatedHash, "Invalid secret or tampered vote");

                    // Tally the vote
                    VoteOption revealedVote = parseVoteFromSecret(secrets[j]);
                    vote.revealed = true;
                    vote.revealedVote = revealedVote;

                    if (revealedVote == VoteOption.For) proposal.votesFor++;
                    else if (revealedVote == VoteOption.Against) proposal.votesAgainst++;
                    else proposal.votesAbstained++;

                    proposal.totalVotes++;
                }

                // Calculate percentages
                if (proposal.totalVotes > 0) {
                    proposal.votesForPercentage = (proposal.votesFor * 1000) / proposal.totalVotes; // Stored as 1dp
                    proposal.votesAgainstPercentage = (proposal.votesAgainst * 1000) / proposal.totalVotes;
                }

                emit ProposalRevealed(i, proposal.votesFor, proposal.votesAgainst, proposal.votesAbstained);
            }
        }
    }

    // Helper: Parse vote from secret
    function parseVoteFromSecret(string memory secret) private pure returns (VoteOption) {
        bytes memory secretBytes = bytes(secret);
        require(secretBytes.length > 0, "Invalid secret");

        if (secretBytes[0] == "F") return VoteOption.For;
        if (secretBytes[0] == "A") return VoteOption.Against;
        return VoteOption.Abstain;
    }

    // Helper: Get all voters for a proposal (example implementation)
    function getVotersForProposal(uint256 proposalId) private view returns (address[] memory) {
        // Implementation to return all voters based on storage structure.
        // Use logs or off-chain tracking if needed.
    }
}
