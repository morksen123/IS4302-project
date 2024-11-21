// defines the contract interface
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface IVotingSystem {
    // Events
    event VotingSessionStarted(uint256 startTime, bytes32[] proposalNames);
    event VotingSessionEnded(uint256 endTime);
    event VoteCast(address indexed voter, uint256 proposalIndex);
    event VotingRightsGranted(address indexed unitAddress);
    event VotingRightsRevoked(address indexed unitAddress);

    // View Functions
    function votingActive() external view returns (bool);
    function lastVotingYear() external view returns (uint256);
    function getWinnerName() external view returns (bytes32);
    function getProposalCount() external view returns (uint256);
    function getProposalName(uint proposalIndex) external view returns (bytes32);
    function getVoteCount(uint proposalIndex) external view returns (uint256);

    // State-Changing Functions
    function startVotingSession(bytes32[] calldata proposalNames) external;
    function endVotingSession() external;
    function grantVotingRights(address unitAddress) external;
    function revokeVotingRights(address unitAddress) external;
    function vote(uint proposalIndex) external;
}
