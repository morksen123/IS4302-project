// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../core/ProposalManager.sol";
import "../core/TreasuryManager.sol";
import "../interfaces/IUnitManager.sol";
import "../storage/VotingStorage.sol";
import "../storage/base/DataStorageBase.sol";

interface IVotingSystem {
    // Getters
    function votingStorage() external view returns (VotingStorage);
    function proposalManager() external view returns (ProposalManager);
    function treasuryManager() external view returns (TreasuryManager);
    function owner() external view returns (address);

    // Functions
    function setProposalManager(ProposalManager _proposalManager) external;
    function setTreasuryManager(TreasuryManager _treasuryManager) external;

    function startVoting() external;
    function commitVote(uint256 proposalId, bytes32 commitHash) external;
    function revealVote(uint256 proposalId, uint256 choice, string calldata secret) external;

    function closeVoting() external;
    function tallyVotes() external;

    function getProposal(uint256 proposalId) external view returns (DataTypes.Proposal memory);
    function getUserCommit(address voter, uint256 proposalId) external view returns (VotingStorage.Commit memory);
}
