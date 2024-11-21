// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";
import "../core/ProposalManager.sol";
import "../core/FeedbackManager.sol";

import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/ProposalStorage.sol";
import "../storage/FeedbackStorage.sol";

contract CondoDAO {
        event Debug(string message);

    // Interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;
    ProposalManager public proposalManager;
    FeedbackManager public feedbackManager;

    // Data Storage
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;
    ProposalStorage private proposalStorage;
    FeedbackStorage private feedbackStorage;

    constructor() public {
        // Initialize Data Storage

        emit Debug("Starting CondoDAO constructor");


        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();
        // proposalStorage = new ProposalStorage();
        // feedbackStorage = new FeedbackStorage();
                emit Debug("Storage contracts initialized");


        // Initialize Interface Contracts
        unitManager = new UnitManager(address(unitStorage));
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        votingSystem = new VotingSystem(address(unitManager));
        // proposalManager = new ProposalManager(address(proposalStorage));
        // feedbackManager = new FeedbackManager(address(feedbackStorage));
                emit Debug("Manager contracts initialized");


        // Set Authorization for Storage Contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));
      //  proposalStorage.addAuthorizedContract(address(proposalManager));
      //  feedbackStorage.addAuthorizedContract(address(feedbackManager));
          emit Debug("Authorization set for manager contracts");

        emit Debug("CondoDAO constructor completed");

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
