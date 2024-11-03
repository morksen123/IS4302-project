const deployContracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions");
var assert = require("assert");

const CondoDAO = artifacts.require("../core/CondoDAO");
const UnitManager = artifacts.require("../core/UnitManager");
const VotingSystem = artifacts.require("../core/VotingSystem");

contract("CondoDAO", (accounts) => {
  let condoDAO;
  let unitManager;
  let votingSystem;
  const [deployer] = accounts;

  before(async () => {
    condoDAO = await CondoDAO.new();
    unitManager = await UnitManager.at(await condoDAO.unitManager());
    votingSystem = await VotingSystem.at(await condoDAO.votingSystem());
  });

  it("should initialize UnitManager and VotingSystem correctly", async () => {
    const unitManagerAddress = await condoDAO.unitManager();
    const votingSystemAddress = await condoDAO.votingSystem();

    console.log("UnitManager Address:", unitManagerAddress);
    console.log("VotingSystem Address:", votingSystemAddress);

    assert(unitManagerAddress !== "0x0", "UnitManager address should be initialized");
    assert(votingSystemAddress !== "0x0", "VotingSystem address should be initialized");
  });
});
