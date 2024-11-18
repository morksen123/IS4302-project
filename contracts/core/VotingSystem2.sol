pragma solidity >=0.5.0 <0.9.0;


import "../interfaces/IVotingSystem2.sol";
import "../interfaces/IUnitManager.sol";
import "../storage/VotingStorage.sol";
import "../types/DataTypes.sol";

contract VotingSystem2 is IVotingSystem2 {
    VotingStorage private votingStorage;
    IUnitManager private unitManager;
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address storageAddress, address unitManagerAddress) public {
      // require(storageAddress != address(0), "Invalid storage address");
      // require(unitManagerAddress != address(0), "Invalid unit manager address");

      votingStorage = VotingStorage(storageAddress);
      unitManager = IUnitManager(unitManagerAddress);
      owner = msg.sender;
    }

    function createProposal(
      address proposer,
      string memory title,
      string memory objectives,
      string memory background,
      string memory implementationPlan,
      string memory budget
  ) external override {
      require(proposer != address(0), "Invalid proposer address");
      require(unitManager.isRegistered(proposer), "Unit not registered");
      require(unitManager.hasVotingRights(proposer), "No voting rights");
      require(!votingStorage.isAGMStarted(), "AGM in session");

      DataTypes.Proposal memory newProposal = DataTypes.Proposal({
          proposer: proposer,
          title: title,
          objectives: objectives,
          background: background,
          implementationPlan: implementationPlan,
          budget: budget,
          dateCreated: block.timestamp,
          votesFor: 0,
          votesAgainst: 0,
          status: DataTypes.ProposalStatus.Submitted
      });

      votingStorage.addProposal(newProposal);
      uint256 proposalId = votingStorage.getProposalCount() - 1; // Use getter to fetch the latest proposal ID
      emit ProposalCreated(proposalId, proposer, title);
    }

    function vote(uint256 proposalId, bool support) external override {
      require(proposalId < votingStorage.getProposalCount(), "Invalid proposal ID");
      require(votingStorage.isAGMStarted(), "AGM not in session");

      DataTypes.Proposal memory proposal = votingStorage.getProposal(proposalId);
      require(proposal.status == DataTypes.ProposalStatus.Pending, "Proposal not pending");
      require(unitManager.isRegistered(msg.sender), "Unit not registered");
      require(unitManager.hasVotingRights(msg.sender), "No voting rights");
      require(!votingStorage.hasUnitVoted(proposalId, msg.sender), "Already voted");

      if (support) {
          proposal.votesFor++;
      } else {
          proposal.votesAgainst++;
      }

      votingStorage.updateProposal(proposalId, proposal);
      votingStorage.recordVote(proposalId, msg.sender);

      emit VoteCast(proposalId, msg.sender, support);
  }

  function getProposal(uint256 proposalId) external view override
    returns (
        address proposer,
        string memory title,
        string memory objectives,
        string memory background,
        string memory implementationPlan,
        string memory budget,
        uint256 dateCreated,
        uint256 votesFor,
        uint256 votesAgainst,
        uint8 status
    ) {
    DataTypes.Proposal memory proposal = votingStorage.getProposal(proposalId);
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
        uint8(proposal.status)
    );
  }

  function startAGMVoting() external override onlyOwner {
      uint256 proposalCount = votingStorage.getProposalCount();

      for (uint256 i = 0; i < proposalCount; i++) {
          DataTypes.Proposal memory proposal = votingStorage.getProposal(i);
          if (proposal.status == DataTypes.ProposalStatus.Submitted) {
              proposal.status = DataTypes.ProposalStatus.Pending;
              votingStorage.updateProposal(i, proposal);
          }
      }

      votingStorage.setAGMStatus(true);
      emit AGMVotingStarted();
  }

}
