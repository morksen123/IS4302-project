// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/ProposalManager.sol";
import "../core/TreasuryManager.sol";

import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";

import "../storage/base/DataStorageBase.sol";
import "../storage/VotingStorage.sol";

contract VotingSystem {
    VotingStorage public votingStorage;
    ProposalManager public proposalManager;
    TreasuryManager public treasuryManager;
    IUnitManager private unitManager;
    address public owner;

    event VoteCommitted(uint256 indexed proposalId, address indexed voter, bytes32 commitHash);
    event VoteRevealed(uint256 indexed proposalId, address indexed voter, VotingStorage.VoteOption choice);
    event VotingStarted();
    event VotingClosed();

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Owner can perform this action");
        _;
    }

    constructor(address _votingStorage, address _unitManager) public {
        require(_votingStorage != address(0), "Invalid vote storage address");
        require(_unitManager != address(0), "Invalid unit manager address");

        owner = msg.sender;
        votingStorage = VotingStorage(_votingStorage);
        unitManager = IUnitManager(_unitManager);
    }

    function setProposalManager(ProposalManager _proposalManager) external onlyOwner {
        require(address(proposalManager) == address(0), "Proposal manager already set");
        proposalManager = _proposalManager;
    }

    function setTreasuryManager(TreasuryManager _treasuryManager) external onlyOwner {
        require(address(treasuryManager) == address(0), "Treasury manager already set");
        treasuryManager = _treasuryManager;
    }

    // Start voting for all currently 
    function startVoting() onlyOwner external {
        uint256 proposalCount = proposalManager.getAllProposals().length;
        for (uint256 i = 0; i < proposalCount; i++) {
            if (proposalManager.getProposal(i).status == DataTypes.ProposalStatus.Submitted) {
                proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.VotingOpen);
            }
        }
        emit VotingStarted();
    }

    // Allow users to commit their vote to the selected proposal
    // Choices: 0 for None, 1 for 'For', 2 for 'Against', 4 for 'Abstain'
    // Commit hashes are created by users using keccak256 SHA-3 standards by encoding (their choice + secret)
    function commitVote(uint256 proposalId, bytes32 commitHash) external {
        DataTypes.Proposal memory proposal = proposalManager.getProposal(proposalId);
        require(proposal.status == DataTypes.ProposalStatus.VotingOpen, "Voting is not open");

        VotingStorage.Commit memory existingCommit = votingStorage.getUserCommit(msg.sender, proposalId);
        require(existingCommit.status == VotingStorage.VoteStatus.None, "Vote already committed");

        require(unitManager.isRegistered(msg.sender), "Unit not registered");
        require(unitManager.hasVotingRights(msg.sender), "Unit does not have voting rights");

        votingStorage.setUserCommit(
            msg.sender,
            proposalId,
            VotingStorage.Commit({
                choice: VotingStorage.VoteOption.None,
                secret: commitHash,
                status: VotingStorage.VoteStatus.Committed
            })
        );

        emit VoteCommitted(proposalId, msg.sender, commitHash);
    }

    // Users to reveal vote upon voting end
    // Votes are verified with their commit hashes by recreating the commit hash with (their vote + secret)
    // 0 for None, 1 for 'For', 2 for 'Against', 4 for 'Abstain'
    function revealVote(uint256 proposalId, uint256 choice, string memory secret) public {
        require(proposalId < proposalManager.getAllProposals().length, "Invalid proposal ID");
        require(proposalManager.getProposal(proposalId).status == DataTypes.ProposalStatus.VotingClosed, "Voting still open");

        // Get commit from commit storage in vote storage to verify
        VotingStorage.Commit memory userCommit = votingStorage.getUserCommit(msg.sender, proposalId);
        require(userCommit.status == VotingStorage.VoteStatus.Committed, "No vote committed or already revealed");
        require(keccak256(abi.encodePacked(choice, secret)) == userCommit.secret, "Hash mismatch");

        VotingStorage.VoteOption convChoice = VotingStorage.VoteOption.None;

        if (choice == 1) convChoice = VotingStorage.VoteOption.For;
        if (choice == 2) convChoice = VotingStorage.VoteOption.Against;
        if (choice == 3) convChoice = VotingStorage.VoteOption.Abstain;

        userCommit.choice = convChoice;
        // Update commit status to "Revealed"
        userCommit.status = VotingStorage.VoteStatus.Revealed;
        votingStorage.setUserCommit(msg.sender, proposalId, userCommit);


        // Increment vote according to Choice
        if (choice == 1) proposalManager.incrementVotes(proposalId, 1,0,0);
        if (choice == 2) proposalManager.incrementVotes(proposalId, 0,1,0);
        if (choice == 3) proposalManager.incrementVotes(proposalId, 0,0,1);

        // votingStorage.updateProposal(proposalId, proposal);
        emit VoteRevealed(proposalId, msg.sender, convChoice);
    }

    // Closes voting for all currently open proposals 
    function closeVoting() onlyOwner public {
        for (uint256 i = 0; i < proposalManager.getAllProposals().length; i++) {

            // Only close voting for proposal if the proposal is open for voting
            if (proposalManager.getProposal(i).status == DataTypes.ProposalStatus.VotingOpen) {
                proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.VotingClosed);
            }
        }

        emit VotingStarted(); // Start Voting
    }

    // tally votes for all proposals (subject to change which proposal to tallyVotes)
    function tallyVotes() onlyOwner public {
        for (uint256 i = 0; i < proposalManager.getAllProposals().length;i++) {

            // Check proposal status is at VotingClosed
            if (proposalManager.getProposal(i).status == DataTypes.ProposalStatus.VotingClosed) {

                uint256 totalVotes = (proposalManager.getVotesFor(i) + proposalManager.getVotesAgainst(i) + proposalManager.getVotesAbstained(i)) * 1000;

                // Check if vote hits minimum quorum of 30%
                uint256 percentageVotes = ((proposalManager.getVotesFor(i) + proposalManager.getVotesAgainst(i)) * 1000 ) / totalVotes;

                // Reject proposal if votes do not pass minimum quorum 30%
                if (percentageVotes < 300) {
                    proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.Rejected);
                    continue;
                }

                // >50% needed to accept proposal 
                if (proposalManager.getVotesFor(i) > proposalManager.getVotesAgainst(i)) {

                    // Check if the suggested budget is within budget, if not reject
                    // if(treasuryManager.getBalance() < proposalManager.getProposal(i).suggestedBudget) {
                    //     proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.Rejected);
                    //     continue;
                    // }

                    //Proposal passes and status is updated to Accepted
                    proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.Accepted);
                    
                } else {
                    proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.Rejected);
                }

            }
        }
    }

    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory) {
        return proposalManager.getProposal(proposalId);
    }

    function getUserCommit(address voter, uint256 proposalId) external view returns (VotingStorage.Commit memory) {
        return votingStorage.getUserCommit(voter, proposalId);
    }

}