const CondoDAO = artifacts.require("../core/CondoDAO");
const VotingSystem = artifacts.require("../core/VotingSystem");
const UnitManager = artifacts.require("../core/UnitManager");

contract("VotingSystem", (accounts) => {
    let votingSystem;
    let unitManager;
    let condoDAO;
    const [deployer, unitProposer, voter1, voter2, voter3, voter4] = accounts; // One proposer, 3 voters for testing

    before(async () => {
        condoDAO = await CondoDAO.deployed();
        unitManager = await UnitManager.at(await condoDAO.unitManager());
        votingSystem = await VotingSystem.at(await condoDAO.votingSystem());

        // Register the unit for the proposer; by default, voting rights are granted
        await unitManager.registerUnit(unitProposer);
        // Register voters
        await unitManager.registerUnit(voter1);
        await unitManager.registerUnit(voter2);
        await unitManager.registerUnit(voter3);
        // Voter 3 revoke voting rights
        await unitManager.updateVotingRights(voter3, false);
        // Voter 4 left unregistered
    });

    it("should create a proposal correctly", async () => {
        const title = "Community Garden Proposal";
        const description = "To establish a community garden for all residents.";
        const solution = "Identify a location, gather volunteers, and plant the garden.";
        const budget = "1000";

        // Create the proposal from the registered unit proposer
        await votingSystem.createProposal(
            unitProposer,
            title,
            description,
            solution,
            budget,
            { from: unitProposer }
        );

        // Fetch the created proposal
        const proposalId = 0; // Assuming this is the first proposal
        const proposal = await votingSystem.proposals(proposalId);

        // Check that the proposal details are correct
        assert.equal(proposal.title, title, "Proposal title should match");
        assert.equal(proposal.description, description, "Description should match");
        assert.equal(proposal.proposedSolution, solution, "Proposed solution should match");
        assert.equal(proposal.suggestedBudget.toString(), budget, "Budget should match");
        assert.equal(proposal.unitAddress, unitProposer, "Proposer address should match");
    });

    it("should not allow a unit to commit a vote before AGM starts", async () => {
        const proposalId = 0;
        const commitHash = web3.utils.keccak256("secretVote");

        try {
            await votingSystem.commitVote(proposalId, commitHash, { from: voter1 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert(error.message.includes("AGM not in session"), "Expected 'AGM not in session' error but got: " + error.message);
        }
    });

    it("should successfully start AGM", async () => {
        await votingSystem.startAGMVoting({ from: deployer });

        const proposalId = 0;
        const proposal = await votingSystem.proposals(proposalId);
        assert.equal(proposal.status.toString(), "1", "Proposal status should be VotingOpen");
    });

    it("should allow a registered voter to commit a vote", async () => {
        const proposalId = 0;
        const commitHash = web3.utils.keccak256(web3.utils.encodePacked("secret1", voter1));

        await votingSystem.commitVote(proposalId, commitHash, { from: voter1 });
        const vote = await votingSystem.votes(proposalId, voter1);

        assert.equal(vote.commitHash, commitHash, "Commit hash should match");
        assert.equal(vote.revealed, false, "Vote should not be revealed yet");
    });

    it("should not allow an unregistered voter to commit a vote", async () => {
        const proposalId = 0;
        const commitHash = web3.utils.keccak256(web3.utils.encodePacked("secret4", voter4));

        try {
            await votingSystem.commitVote(proposalId, commitHash, { from: voter4 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert(error.message.includes("Unit not registered"), "Expected 'Unit not registered' error but got: " + error.message);
        }
    });

    it("should not allow a unit with revoked voting rights to commit a vote", async () => {
        const proposalId = 0;
        const commitHash = web3.utils.keccak256(web3.utils.encodePacked("secret3", voter3));

        try {
            await votingSystem.commitVote(proposalId, commitHash, { from: voter3 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert(error.message.includes("Unit does not have voting rights"), "Expected 'Unit does not have voting rights' error but got: " + error.message);
        }
    });

    it("should close AGM and reveal votes", async () => {
        const secrets = ["secret1"];
        await votingSystem.closeAGM(secrets, { from: deployer });

        const proposalId = 0;
        const proposal = await votingSystem.proposals(proposalId);

        assert.equal(proposal.status.toString(), "2", "Proposal status should be VotingClosed");
        assert.equal(proposal.votesFor.toString(), "1", "Votes for should be 1");
        assert.equal(proposal.votesAgainst.toString(), "0", "Votes against should be 0");
    });

    it("should not allow committing votes after AGM is closed", async () => {
        const proposalId = 0;
        const commitHash = web3.utils.keccak256(web3.utils.encodePacked("secret2", voter2));

        try {
            await votingSystem.commitVote(proposalId, commitHash, { from: voter2 });
            assert.fail("Expected an error but did not get one");
        } catch (error) {
            assert(error.message.includes("AGM not in session"), "Expected 'AGM not in session' error but got: " + error.message);
        }
    });
});
