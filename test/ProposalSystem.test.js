// Import the ProposalManager and DataTypes contracts
const ProposalManager = artifacts.require("ProposalManager");
const ProposalStorage = artifacts.require("ProposalStorage");
const VotingSystem = artifacts.require("VotingSystem");

contract("ProposalManager with VotingSystem", (accounts) => {
  let proposalManager, proposalStorage, votingSystem;
  const [deployer, proposer, voter1] = accounts;
  let proposalId;

  // let proposalManager, proposalStorage, votingSystem;
  // const [deployer, proposer, voter1, voter2] = accounts;

  const TITLE = "Community Garden Proposal";
  const DESCRIPTION = "Proposal to establish a community garden for residents.";
  const SUGGESTED_BUDGET = 1000;
  const PROPOSED_SOLUTION = "Identify a location, gather volunteers, and start planting.";

  // before(async () => {
  //   // Deploy ProposalStorage and ProposalManager contracts
  //   proposalStorage = await ProposalStorage.new();
  //   proposalManager = await ProposalManager.new(proposalStorage.address);

  //   // Deploy VotingSystem contract
  //   votingSystem = await VotingSystem.new(proposalManager.address);

  //   // Set up authorization
  //   await proposalStorage.addAuthorizedContract(proposalManager.address, { from: deployer });
  //   await proposalManager.setVotingContract(votingSystem.address, { from: deployer });
  // });

  before(async () => {
    // Reuse the deployed contracts from migrations
    proposalStorage = await ProposalStorage.deployed();
    proposalManager = await ProposalManager.deployed();

    // Authorize ProposalManager in ProposalStorage
    await proposalStorage.addAuthorizedContract(proposalManager.address, { from: deployer });
  });

  it("should verify that ProposalManager is authorized in ProposalStorage", async () => {
    const isAuthorized = await proposalStorage.authorizedContracts(proposalManager.address);
    console.log("Is ProposalManager authorized?", isAuthorized);
    assert.equal(isAuthorized, true, "ProposalManager should be authorized in ProposalStorage");
  });

  it("should verify that ProposalManager is authorized", async () => {
    const isAuthorized = await proposalStorage.authorizedContracts(proposalManager.address);
    console.log("ProposalManager Address:", proposalManager.address);
    console.log("ProposalStorage Address:", proposalStorage.address);
    assert.equal(isAuthorized, true, "ProposalManager should be authorized");
  });

  describe("Proposal Creation", () => {
    it("should create a new proposal", async () => {
      console.log("proposalmanager", proposalManager.address);
      console.log("proposer", proposer.address);
      const result = await proposalManager.raiseProposal(
        TITLE,
        DESCRIPTION,
        SUGGESTED_BUDGET,
        PROPOSED_SOLUTION,
        { from: proposer }
      );

      // Check the ProposalRaised event
      assert.equal(
        result.logs[0].event,
        "ProposalRaised",
        "ProposalRaised event should be emitted"
      );

      // Retrieve the proposal from storage
      proposalId = result.logs[0].args.proposalId.toNumber();
      const proposal = await proposalStorage.getProposal(proposalId);

      assert.equal(proposal.unitAddress, proposer, "unitAddress should be the creator's address");
      assert.equal(proposal.title, TITLE, "Proposal title should match the input");
      assert.equal(
        proposal.description,
        DESCRIPTION,
        "Proposal description should match the input"
      );
      assert.equal(
        proposal.suggestedBudget.toString(),
        SUGGESTED_BUDGET.toString(),
        "Suggested budget should match the input"
      );
      assert.equal(
        proposal.proposedSolution,
        PROPOSED_SOLUTION,
        "Proposed solution should match the input"
      );
      assert.equal(proposal.status.toString(), "0", "Initial status should be Submitted (0)");
    });
  });

  describe("Voting Workflow", () => {
    let proposalId;

    before(async () => {
      // Create a new proposal for voting
      const result = await proposalManager.raiseProposal(
        TITLE,
        DESCRIPTION,
        SUGGESTED_BUDGET,
        PROPOSED_SOLUTION,
        { from: proposer }
      );
      proposalId = result.logs[0].args.proposalId.toNumber();
    });

    it("should allow the proposer to start voting", async () => {
      await proposalManager.startVoting(proposalId, { from: proposer });

      const proposal = await proposalStorage.getProposal(proposalId);
      assert.equal(proposal.status.toString(), "1", "Proposal status should be VotingOpen (1)");
    });

    it("should restrict starting voting to the proposer", async () => {
      try {
        await proposalManager.startVoting(proposalId, { from: voter1 });
        assert.fail("Expected an error but did not get one");
      } catch (error) {
        assert(error.message.includes("Only the proposer"), "Expected 'Only the proposer' error");
      }
    });

    it("should allow a voter to commit a vote", async () => {
      const secret = "voter1-secret";
      const voteChoice = 1; // Voting "For"
      const commitHash = web3.utils.keccak256(web3.utils.encodePacked(voteChoice, secret));

      await votingSystem.commitVote(proposalId, commitHash, { from: voter1 });
      const commit = await votingSystem.userCommits(voter1, proposalId);

      assert.equal(commit.status, "1", "Vote should be marked as committed");
    });

    it("should allow a voter to reveal their vote", async () => {
      const secret = "voter1-secret";
      const voteChoice = 1; // Voting "For"

      await votingSystem.revealVote(proposalId, voteChoice, secret, { from: voter1 });
      const proposal = await proposalStorage.getProposal(proposalId);

      assert.equal(proposal.votesFor.toString(), "1", "VotesFor should be incremented");
    });

    it("should restrict revealing votes with incorrect secrets", async () => {
      const secret = "wrong-secret";
      const voteChoice = 2; // Voting "Against"

      try {
        await votingSystem.revealVote(proposalId, voteChoice, secret, { from: voter2 });
        assert.fail("Expected an error but did not get one");
      } catch (error) {
        assert(error.message.includes("Hash mismatch"), "Expected 'Hash mismatch' error");
      }
    });

    it("should allow the proposer to close voting", async () => {
      await proposalManager.closeVoting(proposalId, { from: proposer });

      const proposal = await proposalStorage.getProposal(proposalId);
      assert.equal(proposal.status.toString(), "2", "Proposal status should be VotingClosed (2)");
    });

    it("should restrict committing votes after voting is closed", async () => {
      try {
        const commitHash = web3.utils.keccak256(web3.utils.encodePacked(1, "some-secret"));
        await votingSystem.commitVote(proposalId, commitHash, { from: voter2 });
        assert.fail("Expected an error but did not get one");
      } catch (error) {
        assert(error.message.includes("Voting is not open"), "Expected 'Voting is not open' error");
      }
    });

    it("should allow updating proposal status based on votes", async () => {
      // Update the proposal status to Accepted
      await proposalManager.updateProposalStatus(proposalId, 3, { from: votingSystem.address }); // 3 = Accepted

      const proposal = await proposalStorage.getProposal(proposalId);
      assert.equal(proposal.status.toString(), "3", "Proposal status should be Accepted (3)");
    });
  });
});
