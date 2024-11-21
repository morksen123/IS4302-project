// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";


import "../storage/base/DataStorageBase.sol";
import "../storage/VotingStorage.sol";
import "../storage/ProposalStorage.sol";

import "../core/ProposalManager.sol";

contract VotingSystem {
    VotingStorage public votingStorage;
    ProposalManager public proposalManager;
    IUnitManager private unitManager;
    address public owner;

    constructor(address _votingStorage, address _unitManager) public {
        require(_votingStorage != address(0), "Invalid vote storage address");
        require(_unitManager != address(0), "Invalid unit manager address");
        owner = msg.sender;

        votingStorage = VotingStorage(_votingStorage);
        unitManager = IUnitManager(_unitManager);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Owner can perform this action");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    //Set ProposalManager 

    function setProposalContract(ProposalManager _proposalManager) external {
        require(address(proposalManager) == address(0), "Proposal manager already set");
        proposalManager = _proposalManager;
    }

    event VoteCommitted(uint256 proposalId, address indexed voter, bytes32 commitHash);
    event VoteRevealed(uint256 proposalId, address indexed voter, VotingStorage.VoteOption choice);

    event VotingStarted();
    event VotingClosed();

    // function createProposal(
    //     string memory _title,
    //     string memory _description,
    //     string memory _solution,
    //     uint256 _budget
    // ) public {
    //     VotingStorage.Proposal memory newProposal = VotingStorage.Proposal({
    //         proposer: msg.sender,
    //         title: _title,
    //         description: _description,
    //         solution: _solution,
    //         budget: _budget,
    //         status: VotingStorage.ProposalStatus.Submitted,
    //         votesFor: 0,
    //         votesAgainst: 0,
    //         votesAbstained: 0,
    //         totalVotes: 0
    //     });

    //     votingStorage.pushProposal(newProposal);
    //     emit ProposalCreated(votingStorage.getProposalsLength() - 1, msg.sender, _title);
    // }

    // Open Voting for all valid proposals
    function startVoting() public {
        // require(proposalId < proposalStorage.getAllProposals().length, "Invalid proposal ID");
        // DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        // proposal.status = DataTypes.ProposalStatus.VotingOpen;
        for (uint256 i = 0; i < proposalManager.getAllProposals().length; i++) {

            // Only open voting for proposal if the proposal is "submitted"
            if (proposalManager.getProposal(i).status == DataTypes.ProposalStatus.Submitted) {
                proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.VotingOpen);
            }
        }

        emit VotingStarted(); // Start Voting
    }

    // Allow users to commit their vote to the selected proposal
    // Choices: 0 for None, 1 for 'For', 2 for 'Against', 4 for 'Abstain'
    // Commit hashes are created by users using keccak256 SHA-3 standards by encoding (their choice + secret)
    function commitVote(uint256 proposalId, bytes32 commitHash) public {
        require(proposalId < proposalManager.getAllProposals().length, "Invalid proposal ID");
        require(proposalManager.getProposal(proposalId).status == DataTypes.ProposalStatus.VotingOpen, "Voting is not open");
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

    function closeVoting() public {
        // require(proposalId < proposalStorage.getAllProposals().length, "Invalid proposal ID");
        // DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);
        // proposal.status = DataTypes.ProposalStatus.VotingOpen;
        for (uint256 i = 0; i < proposalManager.getAllProposals().length; i++) {

            // Only close voting for proposal if the proposal is open for voting
            if (proposalManager.getProposal(i).status == DataTypes.ProposalStatus.VotingOpen) {
                proposalManager.updateProposalStatus(i, DataTypes.ProposalStatus.VotingClosed);
            }
        }

        emit VotingStarted(); // Start Voting
    }

    // Users to reveal vote upon voting end
    // Votes are verified with their commit hashes by recreating the commit hash with (their vote + secret)
    // 0 for None, 1 for 'For', 2 for 'Against', 4 for 'Abstain'
    function revealVote(uint256 proposalId, uint256 choice, string memory secret) public {
        require(proposalId < proposalManager.getAllProposals().length, "Invalid proposal ID");
        require(proposalManager.getProposal(proposalId).status == DataTypes.ProposalStatus.VotingOpen, "Voting is not open");

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

        // DataTypes.Proposal memory proposal = proposalStorage.getProposal(proposalId);

        // Increment vote according to Choice
        if (choice == 1) proposalManager.incrementVotes(proposalId, 1,0,0);
        if (choice == 2) proposalManager.incrementVotes(proposalId, 0,1,0);
        if (choice == 3) proposalManager.incrementVotes(proposalId, 0,0,1);

        // votingStorage.updateProposal(proposalId, proposal);
        emit VoteRevealed(proposalId, msg.sender, convChoice);
    }

    
    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory) {
        return votingStorage.getProposal(proposalId);
    }

    function getUserCommit(address voter, uint256 proposalId) external view returns (VotingStorage.Commit memory) {
        return votingStorage.getUserCommit(voter, proposalId);
    }

    // function addAuthorizedContract(address UnitManager) external returns ()

}