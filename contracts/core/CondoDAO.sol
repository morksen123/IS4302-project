// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";

import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/VotingStorage.sol";
import "../storage/ProposalStorage.sol";
import "../storage/FeedbackStorage.sol";
import "../oracles/MockPropertyOracle.sol";
import "../core/ProposalManager.sol";
import "../core/FeedbackManager.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;
    ProposalManager public proposalManager;
    FeedbackManager public feedbackManager;
    MockPropertyOracle public mockPropertyOracle;

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
        unitManager = new UnitManager(
            address(unitStorage),
            address(mockPropertyOracle) // Pass oracle address to UnitManager
        );
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(unitManager));
        votingSystem = new VotingSystem(address(votingStorage),address(unitManager));
        proposalManager = new ProposalManager(address(proposalStorage), address(unitManager));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));

        proposalStorage.addAuthorizedContract(address(proposalManager));
        proposalManager.setVotingContract(address(votingSystem));

        votingStorage.addAuthorizedContract(address(votingSystem));
        votingStorage.setUnitManager(address(unitManager));
        votingSystem.setProposalManager(proposalManager);
        votingSystem.setTreasuryManager(treasuryManager);

        

        // Initialize minimum reserve after authorization is set
        treasuryManager.updateMinimumReserve(10 ether);
    }
}
