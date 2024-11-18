const CondoDAO = artifacts.require("../core/CondoDAO");
const VotingSystem2 = artifacts.require("../core/VotingSystem2");
const UnitManager = artifacts.require("../core/UnitManager");
const VotingStorage = artifacts.require("../core/VotingStorage");

contract("VotingSystem2", (accounts) => {
  let votingSystem;
  let unitManager;
  let votingStorage;
  let condoDAO;
  const [deployer,  unitProposer, voter1, voter2, voter3, voter4] = accounts; //one proposer, 3 voters for testing

  before(async () => {
    condoDAO = await CondoDAO.deployed();
    unitManager = await UnitManager.at(await condoDAO.unitManager());
    votingSystem = await VotingSystem2.at(await condoDAO.votingSystem());
    votingStorage = await VotingStorage.at(await votingSystem.votingStorage());

    // Register the unit for the proposer, by default voting rights are granted
    await unitManager.registerUnit(unitProposer);
    // Register voters
    await unitManager.registerUnit(voter1);
    await unitManager.registerUnit(voter2);
    await unitManager.registerUnit(voter3);
    // Revoke voting rights for voter3
    await unitManager.updateVotingRights(voter3, false);
    // Voter4 left unregistered
  });

  it("should create a proposal correctly", async () => {
    const title = "Community Garden Proposal";
    const objectives = "To establish a community garden for all residents.";
    const background = "A community garden will improve aesthetics and provide fresh produce.";
    const implementationPlan = "Identify a location, gather volunteers, and plant the garden.";
    const budget = "1000";

    // Create the proposal
    await votingSystem.createProposal(
      unitProposer,
      title,
      objectives,
      background,
      implementationPlan,
      budget,
      { from: unitProposer }
    );

    // Fetch the proposal from storage
    const proposalId = 0; // Assuming this is the first proposal
    const proposal = await votingStorage.getProposal(proposalId);

    // Check proposal details
    assert.equal(proposal.title, title, "Proposal title should match");
    assert.equal(proposal.objectives, objectives, "Objectives should match");
    assert.equal(proposal.background, background, "Background should match");
    assert.equal(proposal.implementationPlan, implementationPlan, "Implementation plan should match");
    assert.equal(proposal.budget, budget, "Budget should match");
    assert.equal(proposal.proposer, unitProposer, "Proposer address should match");
  });

  it("should not allow a unit to vote before AGM starts", async () => {
    const proposalId = 0;
    try {
      await votingSystem.vote(proposalId, true, { from: voter1 });
      assert.fail("Expected an error but did not get one");
    } catch (error) {
      assert(error.message.includes("AGM not in session"), "Expected 'AGM not in session' error");
    }
  });

  it("should successfully start AGM voting", async () => {
    const result = await votingSystem.startAGMVoting({ from: deployer });

    // Check the event
    const event = result.logs.find((log) => log.event === "AGMVotingStarted");
    assert(event, "AGMVotingStarted event should be emitted");

    // Check all proposals' statuses are updated to Pending
    const proposal = await votingStorage.getProposal(0);
    assert.equal(proposal.status.toString(), "1", "Proposal status should be Pending");
  });

  it("should not allow unregistered or revoked voters to vote", async () => {
    const proposalId = 0;

    // Unregistered voter
    try {
      await votingSystem.vote(proposalId, true, { from: voter4 });
      assert.fail("Expected an error but did not get one");
    } catch (error) {
      assert(error.message.includes("Unit not registered"), "Expected 'Unit not registered' error");
    }

    // Revoked voter
    try {
      await votingSystem.vote(proposalId, true, { from: voter3 });
      assert.fail("Expected an error but did not get one");
    } catch (error) {
      assert(error.message.includes("No voting rights"), "Expected 'No voting rights' error");
    }
  });

  it("should allow registered voters to cast votes", async () => {
    const proposalId = 0;

    // Cast votes
    await votingSystem.vote(proposalId, true, { from: voter1 });
    await votingSystem.vote(proposalId, false, { from: voter2 });

    // Fetch proposal to check vote counts
    const proposal = await votingStorage.getProposal(proposalId);
    assert.equal(proposal.votesFor.toString(), "1", "Votes For should be 1");
    assert.equal(proposal.votesAgainst.toString(), "1", "Votes Against should be 1");
  });

  it("should prevent double voting on the same proposal", async () => {
    const proposalId = 0;

    try {
      await votingSystem.vote(proposalId, true, { from: voter1 });
      assert.fail("Expected an error but did not get one");
    } catch (error) {
      assert(error.message.includes("Already voted"), "Expected 'Already voted' error");
    }
  });
});