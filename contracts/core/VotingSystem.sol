// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";
import "../storage/VotingStorage.sol";

contract VotingSystem {
    VotingStorage public votingStorage;

    modifier onlyProposer(uint256 proposalId) {
        require(msg.sender == votingStorage.getProposal(proposalId).proposer, "Only the proposer can perform this action");
        _;
    }

    constructor(address _votingStorage, address _unitManager) public {
        votingStorage = VotingStorage(_votingStorage);
        votingStorage.setUnitManager(_unitManager);
    }

    event ProposalCreated(uint256 proposalId, address indexed proposer, string title);
    event VoteCommitted(uint256 proposalId, address indexed voter, bytes32 commitHash);
    event VoteRevealed(uint256 proposalId, address indexed voter, VotingStorage.VoteOption choice);
    event VotingStarted(uint256 proposalId);
    event VotingClosed(uint256 proposalId, VotingStorage.ProposalStatus result);

    function createProposal(
        string memory _title,
        string memory _description,
        string memory _solution,
        uint256 _budget
    ) public {
        VotingStorage.Proposal memory newProposal = VotingStorage.Proposal({
            proposer: msg.sender,
            title: _title,
            description: _description,
            solution: _solution,
            budget: _budget,
            status: VotingStorage.ProposalStatus.Submitted,
            votesFor: 0,
            votesAgainst: 0,
            votesAbstained: 0,
            totalVotes: 0
        });

        votingStorage.pushProposal(newProposal);
        emit ProposalCreated(votingStorage.getProposalsLength() - 1, msg.sender, _title);
    }

    function startVoting(uint256 proposalId) public onlyProposer(proposalId) {
        require(proposalId < votingStorage.getProposalsLength(), "Invalid proposal ID");
        VotingStorage.Proposal memory proposal = votingStorage.getProposal(proposalId);
        proposal.status = VotingStorage.ProposalStatus.VotingOpen;
        votingStorage.updateProposal(proposalId, proposal);
        emit VotingStarted(proposalId);
    }

    function commitVote(uint256 proposalId, bytes32 commitHash) public {
        require(proposalId < votingStorage.getProposalsLength(), "Invalid proposal ID");
        require(votingStorage.getProposal(proposalId).status == VotingStorage.ProposalStatus.VotingOpen, "Voting is not open");
        require(votingStorage.getUserCommit(msg.sender, proposalId).status == VotingStorage.VoteStatus.None, "Already committed a vote");
        require(votingStorage.getUnitManager().isRegistered(msg.sender), "Unit not registered");
        require(votingStorage.getUnitManager().hasVotingRights(msg.sender), "Unit does not have voting rights");

        VotingStorage.Commit memory newCommit = VotingStorage.Commit({
            choice: VotingStorage.VoteOption.None,
            secret: commitHash,
            status: VotingStorage.VoteStatus.Committed
        });
        
        votingStorage.setUserCommit(msg.sender, proposalId, newCommit);
        emit VoteCommitted(proposalId, msg.sender, commitHash);
    }

    function revealVote(uint256 proposalId, VotingStorage.VoteOption choice, string memory secret) public {
        require(proposalId < votingStorage.getProposalsLength(), "Invalid proposal ID");
        require(votingStorage.getProposal(proposalId).status == VotingStorage.ProposalStatus.VotingOpen, "Voting is not open");

        VotingStorage.Commit memory userCommit = votingStorage.getUserCommit(msg.sender, proposalId);
        require(userCommit.status == VotingStorage.VoteStatus.Committed, "No vote committed or already revealed");
        require(keccak256(abi.encodePacked(uint256(choice), secret)) == userCommit.secret, "Hash mismatch");

        userCommit.choice = choice;
        userCommit.status = VotingStorage.VoteStatus.Revealed;
        votingStorage.setUserCommit(msg.sender, proposalId, userCommit);

        VotingStorage.Proposal memory proposal = votingStorage.getProposal(proposalId);
        proposal.totalVotes++;

        if (choice == VotingStorage.VoteOption.For) proposal.votesFor++;
        if (choice == VotingStorage.VoteOption.Against) proposal.votesAgainst++;
        if (choice == VotingStorage.VoteOption.Abstain) proposal.votesAbstained++;

        votingStorage.updateProposal(proposalId, proposal);
        emit VoteRevealed(proposalId, msg.sender, choice);
    }

    function closeVoting(uint256 proposalId) public onlyProposer(proposalId) {
        require(proposalId < votingStorage.getProposalsLength(), "Invalid proposal ID");
        require(votingStorage.getProposal(proposalId).status == VotingStorage.ProposalStatus.VotingOpen, "Voting is not open");

        VotingStorage.Proposal memory proposal = votingStorage.getProposal(proposalId);
        proposal.status = VotingStorage.ProposalStatus.VotingClosed;
        votingStorage.updateProposal(proposalId, proposal);

        emit VotingClosed(proposalId, proposal.status);
    }

    function getProposal(uint256 proposalId) external view returns (VotingStorage.Proposal memory) {
        return votingStorage.getProposal(proposalId);
    }

    function getUserCommit(address voter, uint256 proposalId) external view returns (VotingStorage.Commit memory) {
        return votingStorage.getUserCommit(voter, proposalId);
}



}