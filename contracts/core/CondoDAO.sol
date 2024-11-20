// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";
import "../core/FacilityManager.sol";
import "../oracles/MockPropertyOracle.sol";

import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/FacilityStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;
    FacilityManager public facilityManager;
    MockPropertyOracle public mockPropertyOracle;

    // data
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;
    FacilityStorage private facilityStorage;

    constructor() public {
        // initialize data storage
        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();
        facilityStorage = new FacilityStorage();

        // initialize interface contracts
        mockPropertyOracle = new MockPropertyOracle();
        unitManager = new UnitManager(
            address(unitStorage),
            address(mockPropertyOracle)
        );
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        votingSystem = new VotingSystem(address(unitManager));
        facilityManager = new FacilityManager(address(facilityStorage), address(unitManager));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));
        facilityStorage.addAuthorizedContract(address(facilityManager));

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
