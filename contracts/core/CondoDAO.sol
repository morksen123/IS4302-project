// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";


import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;

    // data
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;

    constructor() public {
        // initialize data storage
        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();

        // initialize interface contracts
        unitManager = new UnitManager(address(unitStorage));
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        votingSystem = new VotingSystem(address(unitManager));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
