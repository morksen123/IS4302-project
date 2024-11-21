const CondoDAO = artifacts.require("../core/CondoDAO");
const VotingSystem = artifacts.require("../core/VotingSystem");
const UnitManager = artifacts.require("../core/UnitManager");

contract("VotingSystem", (accounts) => {
    let votingSystem;
    let unitManager;
    let condoDAO;
    const [deployer, unitProposer, voter1, voter2, voter3, voter4] = accounts;

    before(async () => {
        condoDAO = await CondoDAO.deployed();
        unitManager = await UnitManager.at(await condoDAO.unitManager());
        votingSystem = await VotingSystem.at(await condoDAO.votingSystem());

        // Register proposer and voters
        await unitManager.registerUnit(unitProposer);
        await unitManager.registerUnit(voter1);
        await unitManager.registerUnit(voter2);
        await unitManager.registerUnit(voter3);
        // Revoke voting rights for voter3
        await unitManager.updateVotingRights(voter3, false);
        // Leave voter4 unregistered
    });

    describe("Proposal Lifecycle", () => {
        it("should create a proposal correctly", async () => {
            const title = "Community Garden Proposal";
            const description = "To establish a community garden for all residents.";
            const solution = "Identify a location, gather volunteers, and plant the garden.";
            const budget = "1000";

            await votingSystem.createProposal(title, description, solution, budget, { from: unitProposer });
            const proposal = await votingSystem.proposals(0);

            assert.equal(proposal.title, title, "Proposal title should match");
            assert.equal(proposal.description, description, "Proposal description should match");
            assert.equal(proposal.solution, solution, "Proposed solution should match");
            assert.equal(proposal.budget.toString(), budget, "Budget should match");
            assert.equal(proposal.proposer, unitProposer, "Proposer address should match");
        });

        it("should restrict starting voting to the proposer", async () => {
            const proposalId = 0;

            try {
                await votingSystem.startVoting(proposalId, { from: voter1 });
                assert.fail("Expected an error but did not get one");
            } catch (error) {
                assert(error.message.includes("Only the proposer"), "Expected 'Only the proposer' error");
            }
        });

        it("should allow the proposer to start voting", async () => {
            const proposalId = 0;

            await votingSystem.startVoting(proposalId, { from: unitProposer });
            const proposal = await votingSystem.proposals(proposalId);

            assert.equal(proposal.status.toString(), "1", "Proposal status should be VotingOpen");
        });
    });

    describe("Vote Commitment", () => {
      it("should allow a registered voter to commit a vote", async () => {
          const proposalId = 0;
          const secret = "secret1";
          const voteChoice = 1; // Voting "For"
          const commitHash = web3.utils.keccak256(web3.utils.encodePacked(voteChoice, secret));
  
          await votingSystem.commitVote(proposalId, commitHash, { from: voter1 });
          const commit = await votingSystem.userCommits(voter1, proposalId);
  
          assert.equal(commit.status, "1", "Vote should be marked as committed");
      });
  
      it("should reject commit votes from unregistered units", async () => {
          const proposalId = 0;
  
          try {
              const commitHash = web3.utils.keccak256(web3.utils.encodePacked(2, "secret4"));
              await votingSystem.commitVote(proposalId, commitHash, { from: voter4 });
              assert.fail("Expected an error but did not get one");
          } catch (error) {
              assert(error.message.includes("Unit not registered"), "Expected 'Unit not registered' error");
          }
      });
  
      it("should reject commit votes from units with revoked voting rights", async () => {
          const proposalId = 0;
  
          try {
              const commitHash = web3.utils.keccak256(web3.utils.encodePacked(2, "secret3"));
              await votingSystem.commitVote(proposalId, commitHash, { from: voter3 });
              assert.fail("Expected an error but did not get one");
          } catch (error) {
              assert(error.message.includes("Unit does not have voting rights"), "Expected 'Unit does not have voting rights' error");
          }
      });
  });
  
  describe("Vote Reveal", () => {
      it("should allow a voter to reveal their vote", async () => {
          const proposalId = 0;
          const secret = "secret1";
          const voteChoice = 1; // Voting "For"
          
          // Commit the vote first
          const commitHash = web3.utils.keccak256(web3.utils.encodePacked(voteChoice, secret));
          // await votingSystem.commitVote(proposalId, commitHash, { from: voter1 });
  
          // Now reveal the vote with the same secret and choice
          await votingSystem.revealVote(proposalId, voteChoice, secret, { from: voter1 });
  
          const proposal = await votingSystem.proposals(proposalId);
          const commit = await votingSystem.userCommits(voter1, proposalId);
  
          assert.equal(proposal.votesFor.toString(), "1", "Votes for should be incremented");
          assert.equal(commit.status, "2", "Vote should be marked as revealed");
      });
  
      it("should reject revealing invalid votes", async () => {
          const proposalId = 0;
          const secret = "secret2";
          const voteChoice = 2; // Voting "For"
          const commitHash = web3.utils.keccak256(web3.utils.encodePacked(voteChoice, secret));
  
          await votingSystem.commitVote(proposalId, commitHash, { from: voter2 });
  
          const invalidSecret = "wrongSecret"; // A different secret than what was committed
          const invalidVoteChoice = 2; // Voting "Against" (or any invalid choice)
  
          try {
              await votingSystem.revealVote(proposalId, invalidVoteChoice, invalidSecret, { from: voter2 });
              assert.fail("Expected 'Hash mismatch' error but did not get one");
          } catch (error) {
              assert(error.message.includes("Hash mismatch"), "Expected 'Hash mismatch' error");
          }
      });
  });
  
  describe("Close Voting", () => {
      it("should allow the proposer to close voting and tally votes", async () => {
          const proposalId = 0;
  
          await votingSystem.closeVoting(proposalId, { from: unitProposer });
  
          const proposal = await votingSystem.proposals(proposalId);
          assert.equal(proposal.status.toString(), "2", "Proposal status should be VotingClosed");
      });
  
      it("should reject committing votes after voting is closed", async () => {
          const proposalId = 0;
  
          try {
              const commitHash = web3.utils.keccak256(web3.utils.encodePacked("A", "secret2"));
              await votingSystem.commitVote(proposalId, commitHash, { from: voter2 });
              assert.fail("Expected an error but did not get one");
          } catch (error) {
              assert(error.message.includes("Voting is not open"), "Expected 'Voting is not open' error");
          }
      });
  });
  
});
