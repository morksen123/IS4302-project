// // Import the ProposalManager and DataTypes contracts
// const ProposalManager = artifacts.require("ProposalManager");
// const ProposalStorage = artifacts.require("ProposalStorage");

// contract("ProposalManager", (accounts) => {
//   let proposalManager;
//   let proposalStorage;

//   const TITLE = "New Gym Proposal";
//   const DESCRIPTION = "Proposal to add a new gym facility";
//   const SUGGESTED_BUDGET = 1000; // Example budget
//   const PROPOSED_SOLUTION = "Purchase new equipment and renovate the area";

//   before(async () => {
//     // Deploy ProposalStorage and ProposalManager contracts
//     proposalStorage = await ProposalStorage.new();
//     proposalManager = await ProposalManager.new(proposalStorage.address);

//   });

//   it("should create a new proposal", async () => {
//     // Call the raiseProposal function with sample data
//     const result = await proposalManager.raiseProposal(
//       TITLE,
//       DESCRIPTION,
//       SUGGESTED_BUDGET,
//       PROPOSED_SOLUTION,
//       { from: accounts[0] }
//     );

//     // Check that the ProposalRaised event was emitted
//     assert.equal(result.logs[0].event, "ProposalRaised", "ProposalRaised event should be emitted");

//     // Verify proposal data stored in the ProposalStorage contract
//     const proposalId = result.logs[0].args.proposalId.toNumber();
//     const proposal = await proposalStorage.getProposal(proposalId);

//     assert.equal(proposal.unitAddress, accounts[0], "unitAddress should be the creator's address");
//     assert.equal(proposal.title, TITLE, "Proposal title should match the input");
//     assert.equal(proposal.description, DESCRIPTION, "Proposal description should match the input");
//     assert.equal(
//       proposal.suggestedBudget.toString(),
//       SUGGESTED_BUDGET.toString(),
//       "Suggested budget should match the input"
//     );
//     assert.equal(
//       proposal.proposedSolution,
//       PROPOSED_SOLUTION,
//       "Proposed solution should match the input"
//     );
//     assert.equal(proposal.status.toString(), "0", "Initial status should be Draft (0)");
//   });

//   it("should update the proposal status", async () => {
//     // Create a proposal first
//     const result = await proposalManager.raiseProposal(
//       TITLE,
//       DESCRIPTION,
//       SUGGESTED_BUDGET,
//       PROPOSED_SOLUTION,
//       { from: accounts[0] }
//     );
//     const proposalId = result.logs[0].args.proposalId.toNumber();

//     // Update the proposal status to OpenForVoting
//     await proposalManager.updateProposalStatus(proposalId, 1); // 1 represents OpenForVoting

//     // Verify the status update in the storage contract
//     const updatedProposal = await proposalStorage.getProposal(proposalId);
//     assert.equal(
//       updatedProposal.status.toString(),
//       "1",
//       "Status should be updated to OpenForVoting (1)"
//     );
//   });

//   it("should revert if trying to update status of non-existent proposal", async () => {
//     try {
//       await proposalManager.updateProposalStatus(9999, 1); // Trying to update a non-existent proposal
//       assert.fail("Expected revert not received");
//     } catch (error) {
//       assert(error.message.includes("Invalid proposal ID"), "Expected 'Invalid proposal ID' error");
//     }
//   });

//   it("should retrieve the correct proposal data", async () => {
//     // Create a new proposal
//     const result = await proposalManager.raiseProposal(
//       "Community Pool Upgrade",
//       "Upgrade the pool area with new tiles and seating",
//       1500,
//       "Purchase materials and hire contractors",
//       { from: accounts[1] }
//     );

//     const proposalId = result.logs[0].args.proposalId.toNumber();
//     const proposal = await proposalManager.getProposal(proposalId);

//     assert.equal(
//       proposal.unitAddress,
//       accounts[1],
//       "unitAddress should match the creator's address"
//     );
//     assert.equal(
//       proposal.title,
//       "Community Pool Upgrade",
//       "Title should match the created proposal title"
//     );
//     assert.equal(
//       proposal.suggestedBudget.toString(),
//       "1500",
//       "Suggested budget should match the created proposal's budget"
//     );
//   });
// });
