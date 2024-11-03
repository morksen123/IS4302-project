// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";

import "../storage/UnitStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;

    // data
    UnitStorage private unitStorage;

    constructor() public {
        // initialize data storage
        unitStorage = new UnitStorage();

        // initialize interface contracts
        unitManager = new UnitManager(address(unitStorage));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
    }
}
