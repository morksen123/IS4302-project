const CondoDAO = artifacts.require("CondoDAO");

module.exports = (deployer, network, accounts) => {
  deployer.deploy(CondoDAO);
};
