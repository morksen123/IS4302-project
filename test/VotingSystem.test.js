const CondoDAO = artifacts.require("../core/CondoDAO");
const VotingSystem = artifacts.require("../core/VotingSystem");
const UnitManager = artifacts.require("../core/UnitManager");

contract("VotingSystem", (accounts) => {
  let votingSystem;
  let unitManager;
  let condoDAO;
  const [deployer,  unitProposer, voter1, voter2] = accounts; //one proposer, 2 voters for testing

  before(async () => {
    condoDAO = await CondoDAO.deployed();
    unitManager = await UnitManager.at(await condoDAO.unitManager());
    votingSystem = await VotingSystem.at(await condoDAO.votingSystem());

    // Register the unit for the proposer, by default voting rights are granted
    await unitManager.registerUnit(unitProposer); 
    // Register voters
    await unitManager.registerUnit(voter1); 
    await unitManager.registerUnit(voter2); 
  });

  it("should create a proposal correctly", async () => {
    const title = "Community Garden Proposal";
    const objectives = "To establish a community garden for all residents.";
    const background = "A community garden will improve aesthetics and provide fresh produce.";
    const implementationPlan = "Identify a location, gather volunteers, and plant the garden.";
    const budget = "1000"; // Example budget

    // Create the proposal from the registered unit proposer
    await votingSystem.createProposal(
      unitProposer,
      title,
      objectives,
      background,
      implementationPlan,
      budget
    );

    // Fetch the created proposal
    const proposalId = 0; // Assuming this is the first proposal
    const proposal = await votingSystem.getProposal(proposalId);

    // Check that the proposal details are correct
    assert.equal(proposal.title, title, "Proposal title should match");
    assert.equal(proposal.objectives, objectives, "Objectives should match");
    assert.equal(proposal.background, background, "Background should match");
    assert.equal(proposal.implementationPlan, implementationPlan, "Implementation plan should match");
    assert.equal(proposal.budget, budget, "Budget should match");
    assert.equal(proposal.proposer, unitProposer, "Proposer address should match");
  });

  it("should allow a registered voter to cast a vote", async () => {
    // Voter 1 already registered, proposal already created
    const proposalId = 0;
    const voterAddress = voter1; 

    // Cast the vote
    await votingSystem.vote(proposalId, true, { from: voterAddress });
    const proposal = await votingSystem.proposals(proposalId);

    // Check that the vote count has increased
    assert.equal(proposal.votesFor.toString(), '1', "Vote count should be 1 after voting");
  });

  it("should not allow a unit to vote more than once on the same proposal", async () => {
    const proposalId = 0;
    const voterAddress = voter1; 

    try {
        await votingSystem.vote(proposalId, true, { from: voterAddress });
        assert.fail("Expected an error but did not get one");
    } catch (error) {
        assert(error.message.includes("Unit already voted on this proposal"), "Expected 'Unit already voted on this proposal' error but got: " + error.message);
    }
  });
});