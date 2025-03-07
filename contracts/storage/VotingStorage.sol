// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IVotingSystem.sol";
import "../interfaces/IUnitManager.sol";

import "../core/ProposalManager.sol";

import "../storage/base/DataStorageBase.sol";
import "../storage/ProposalStorage.sol";

import "../types/DataTypes.sol";

contract VotingStorage is DataStorageBase {
    ProposalStorage public proposalStorage;

    enum VoteOption { None, For, Against, Abstain }
    // enum ProposalStatus { Submitted, VotingOpen, VotingClosed, Accepted, Rejected }
    enum VoteStatus { None, Committed, Revealed }

    struct Commit {
        VoteOption choice;
        bytes32 secret;
        VoteStatus status;
    }

    // Storage variables
    mapping(address => mapping(uint256 => Commit)) public userCommits;
    IUnitManager public unitManager;

    // Getter functions


    function getProposal(uint256 proposalId) public view returns (DataTypes.Proposal memory) {
        return proposalStorage.getProposal(proposalId);
    }

    function getProposalsLength() public view returns (uint256) {
        return proposalStorage.getAllProposals().length;
    }

    function getUserCommit(address user, uint256 proposalId) public view returns (Commit memory) {
        return userCommits[user][proposalId];
    }

    function getUnitManager() public view returns (IUnitManager) {
        return unitManager;
    }

    // Setter functions
    function setUnitManager(address _unitManager) public {
        unitManager = IUnitManager(_unitManager);
    }

    function setUserCommit(address user, uint256 proposalId, Commit memory commit) public {
        userCommits[user][proposalId] = commit;
    }
}