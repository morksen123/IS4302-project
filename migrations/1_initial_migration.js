// const Migrations = artifacts.require("Migrations");

// module.exports = function(deployer) {
//   deployer.deploy(Migrations);
// };

const Migrations = artifacts.require("Migrations");

module.exports = async function (deployer) {
  try {
    console.log("Deploying Migrations contract...");
    await deployer.deploy(Migrations);
    console.log("Migrations deployed successfully");
  } catch (error) {
    console.error("Deployment error:", error);
  }
};
