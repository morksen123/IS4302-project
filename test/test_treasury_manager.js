const CondoDAO = artifacts.require("CondoDAO");
const TreasuryManager = artifacts.require("TreasuryManager");

contract("TreasuryManager", (accounts) => {
  const [owner] = accounts;
  let condoDAO;
  let treasuryManager;

  beforeEach(async () => {
    condoDAO = await CondoDAO.new();
    const treasuryManagerAddress = await condoDAO.treasuryManager();
    treasuryManager = await TreasuryManager.at(treasuryManagerAddress);
  });

  describe("Basic Treasury Functions", () => {
    it("should initialize with correct minimum reserve", async () => {
      const minReserve = await treasuryManager.getMinimumReserve();
      assert.equal(web3.utils.fromWei(minReserve), 10, "Initial minimum reserve should be 10 ETH");
    });

    it("should accept funds", async () => {
      const amount = web3.utils.toWei("1", "ether");
      await web3.eth.sendTransaction({
        from: owner,
        to: treasuryManager.address,
        value: amount,
      });

      const balance = await treasuryManager.getBalance();
      assert.equal(web3.utils.fromWei(balance), "1", "Balance should be 1 ETH");
    });
  });
});
