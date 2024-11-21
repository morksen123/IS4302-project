// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";

import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/VotingStorage.sol";
import "../storage/ProposalStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;
    ProposalManager public proposalManager;

    // data
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;
    VotingStorage private votingStorage;
    ProposalStorage private proposalStorage;

    constructor() public {
        // initialize data storage
        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();
        proposalStorage = new ProposalStorage();
        votingStorage = new VotingStorage();

        // initialize interface contracts
        unitManager = new UnitManager(address(unitStorage));
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        votingSystem = new VotingSystem(address(votingStorage),address(unitManager));
        proposalManager = new ProposalManager(address(proposalStorage));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));

        proposalStorage.addAuthorizedContract(address(proposalManager));
        proposalManager.setVotingContract(address(votingSystem));

        votingStorage.addAuthorizedContract(address(votingSystem));
        votingSystem.setProposalContract(proposalManager);

        

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
