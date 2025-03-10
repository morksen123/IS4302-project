// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/UnitManager.sol";
import "../core/TreasuryManager.sol";
import "../core/VotingSystem.sol";
import "../core/FacilityManager.sol";
import "../oracles/MockPropertyOracle.sol";

import "../storage/UnitStorage.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/VotingStorage.sol";
import "../storage/ProposalStorage.sol";
import "../storage/FeedbackStorage.sol";
import "../oracles/MockPropertyOracle.sol";
import "../core/ProposalManager.sol";
import "../core/FeedbackManager.sol";
import "../storage/FacilityStorage.sol";

contract CondoDAO {
    // interfaces
    UnitManager public unitManager;
    TreasuryManager public treasuryManager;
    VotingSystem public votingSystem;
    ProposalManager public proposalManager;
    FeedbackManager public feedbackManager;
    FacilityManager public facilityManager;

    MockPropertyOracle public mockPropertyOracle;

    // data
    UnitStorage private unitStorage;
    TreasuryStorage private treasuryStorage;
    VotingStorage private votingStorage;
    ProposalStorage private proposalStorage;
    FacilityStorage private facilityStorage;


    constructor() {
        // initialize data storage
        unitStorage = new UnitStorage();
        treasuryStorage = new TreasuryStorage();
        proposalStorage = new ProposalStorage();
        votingStorage = new VotingStorage();
        facilityStorage = new FacilityStorage();

        // initialize interface contracts
        mockPropertyOracle = new MockPropertyOracle();
        unitManager = new UnitManager(
            address(unitStorage),
            address(mockPropertyOracle)
        );
        treasuryManager = new TreasuryManager(address(treasuryStorage), address(proposalManager), address(unitManager));
        votingSystem = new VotingSystem(address(votingStorage),address(unitManager));
        proposalManager = new ProposalManager(address(proposalStorage), address(unitManager));
        votingSystem = new VotingSystem(address(votingStorage), address(unitManager));
        facilityManager = new FacilityManager(address(facilityStorage), address(unitManager));

        // Set authorization for storage contracts
        unitStorage.addAuthorizedContract(address(unitManager));
        treasuryStorage.addAuthorizedContract(address(treasuryManager));
        facilityStorage.addAuthorizedContract(address(facilityManager));

        proposalStorage.addAuthorizedContract(address(proposalManager));
        proposalManager.setVotingContract(address(votingSystem));

        votingStorage.addAuthorizedContract(address(votingSystem));
        votingStorage.setUnitManager(address(unitManager));
        votingSystem.setProposalManager(proposalManager);

        

        proposalStorage.addAuthorizedContract(address(proposalManager));
        proposalManager.setVotingContract(address(votingSystem));

        votingStorage.addAuthorizedContract(address(votingSystem));
        votingStorage.setUnitManager(address(unitManager));
        votingSystem.setProposalManager(proposalManager);
        votingSystem.setTreasuryManager(treasuryManager);

        

        // Initialize minimum reserve after authorization is set
        // treasuryManager.updateMinimumReserve(10 ether);
    }
}
