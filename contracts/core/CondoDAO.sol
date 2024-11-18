// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";
import "../core/VotingSystem2.sol";


import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/VotingStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    //VotingSystem public votingSystem;
    //VotingSystem2 public votingSystem2;

    // data
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;
    //VotingStorage private votingStorage;

    constructor() public {
        // initialize data storage
        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();
        //votingStorage = new VotingStorage();

        // initialize interface contracts
        unitManager = new UnitManager(address(unitStorage));
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        //votingSystem = new VotingSystem(address(unitManager));
        //votingSystem2 = new VotingSystem2(address(votingStorage), address(unitManager));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));
        //votingStorage.addAuthorizedContract(address(votingSystem2));

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
