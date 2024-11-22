const CondoDAO = artifacts.require("CondoDAO");
const ProposalStorage = artifacts.require("ProposalStorage");
const ProposalManager = artifacts.require("ProposalManager");
const VotingSystem = artifacts.require("VotingSystem");

module.exports = async function (deployer, network, accounts) {
  const [deployerAddress] = accounts;

  deployer.deploy(CondoDAO);

  // Deploy the ProposalStorage contract
  await deployer.deploy(ProposalStorage);
  const proposalStorage = await ProposalStorage.deployed();
  console.log("ProposalStorage Address:", proposalStorage.address);

  // Deploy the ProposalManager contract
  await deployer.deploy(ProposalManager, proposalStorage.address);
  const proposalManager = await ProposalManager.deployed();
  console.log("ProposalManager Address:", proposalManager.address);

  // Deploy the VotingSystem contract
  await deployer.deploy(VotingSystem, proposalManager.address);
  const votingSystem = await VotingSystem.deployed();

  // Authorize ProposalManager to interact with ProposalStorage
  await proposalStorage.addAuthorizedContract(proposalManager.address, { from: deployerAddress });

  // Authorize VotingSystem to interact with ProposalManager, if required
  await proposalManager.setVotingContract(votingSystem.address);
};
