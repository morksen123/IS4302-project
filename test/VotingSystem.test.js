const VotingStorage = artifacts.require("../storage/VotingStorage");
const UnitManager = artifacts.require("../core/UnitManager");
const ProposalStorage = artifacts.require("../storage/ProposalStorage");
const ProposalManager = artifacts.require("../core/ProposalManager");
const DataTypes = artifacts.require("../types/DataTypes");

contract("VotingStorage", (accounts) => {
    let votingStorage;
    let unitManager;
    let proposalStorage;
    let proposalManager;
    const [owner, unitProposer, voter1, voter2, voter3, nonVoter] = accounts;

    beforeEach(async () => {
        // Deploy UnitManager
        unitManager = await UnitManager.new();
        await unitManager.registerUnit(unitProposer);
        await unitManager.registerUnit(voter1);
        await unitManager.registerUnit(voter2);
        await unitManager.registerUnit(voter3);

        // Grant voting rights
        await unitManager.grantVotingRights(unitProposer);
        await unitManager.grantVotingRights(voter1);
        await unitManager.grantVotingRights(voter2);
        await unitManager.grantVotingRights(voter3);

        // Deploy ProposalStorage
        proposalStorage = await ProposalStorage.new();

        // Deploy VotingStorage
        votingStorage = await VotingStorage.new();
        await votingStorage.setUnitManager(unitManager.address);

        // Deploy ProposalManager
        proposalManager = await ProposalManager.new(proposalStorage.address);
    });

    describe("Initialization", () => {
        it("should set unit manager correctly", async () => {
            const storedUnitManager = await votingStorage.getUnitManager();
            assert.equal(storedUnitManager, unitManager.address, "Unit manager not set correctly");
        });
    });

    describe("User Commits", () => {
        let proposalId;

        beforeEach(async () => {
            // Create a proposal
            await proposalManager.raiseProposal(
                "Test Proposal",
                "A test proposal description",
                1000,
                "Test Solution"
            );
            proposalId = 0; // First proposal
        });

        it("should allow setting and getting user commits", async () => {
            // Prepare commit data
            const choice = 1; // For
            const secret = web3.utils.soliditySha3(
                { t: 'uint256', v: choice },
                { t: 'string', v: "test_secret" }
            );
            
            const commit = {
                choice: choice,
                secret: secret,
                status: 1 // Committed
            };

            // Set user commit
            await votingStorage.setUserCommit(voter1, proposalId, commit);

            // Get user commit
            const retrievedCommit = await votingStorage.getUserCommit(voter1, proposalId);
            
            assert.equal(retrievedCommit.choice, choice, "Commit choice not stored correctly");
            assert.equal(retrievedCommit.secret, secret, "Commit secret not stored correctly");
            assert.equal(retrievedCommit.status, 1, "Commit status not stored correctly");
        });

        it("should allow retrieving proposal from proposal storage", async () => {
            // Get proposal from storage
            const proposal = await votingStorage.getProposal(proposalId);
            
            assert.equal(proposal.title, "Test Proposal", "Proposal not retrieved correctly");
        });

        it("should return correct proposals length", async () => {
            // Create another proposal
            await proposalManager.raiseProposal(
                "Second Test Proposal",
                "Another test proposal description",
                2000,
                "Another Test Solution"
            );

            const proposalsLength = await votingStorage.getProposalsLength();
            assert.equal(proposalsLength, 2, "Incorrect number of proposals");
        });
    });

    describe("Vote Options and Statuses", () => {
        it("should have correct vote options enum", async () => {
            const voteOptions = {
                None: 0,
                For: 1,
                Against: 2,
                Abstain: 3
            };

            const contractVoteOptions = await votingStorage.getUserCommit(accounts[0], 0);
            
            assert.equal(
                contractVoteOptions.choice, 
                voteOptions.None, 
                "Vote options enum does not match expected values"
            );
        });

        it("should have correct vote status enum", async () => {
            const voteStatuses = {
                None: 0,
                Committed: 1,
                Revealed: 2
            };

            const contractCommit = await votingStorage.getUserCommit(accounts[0], 0);
            
            assert.equal(
                contractCommit.status, 
                voteStatuses.None, 
                "Vote status enum does not match expected values"
            );
        });
    });

    describe("Error Handling", () => {
        it("should revert when trying to get user commit for non-existent proposal", async () => {
            try {
                await votingStorage.getUserCommit(voter1, 9999);
                assert.fail("Should have thrown an error");
            } catch (error) {
                assert(error.message.includes("revert") || error.message.includes("invalid"), 
                    "Expected a revert or invalid error");
            }
        });
    });
});

// Utility function for expecting reverts
async function expectRevert(promise, errorMessage) {
    try {
        await promise;
        assert.fail('Expected revert not received');
    } catch (error) {
        assert(
            error.message.includes(errorMessage),
            `Expected "${errorMessage}", got "${error.message}" instead`
        );
    }
}