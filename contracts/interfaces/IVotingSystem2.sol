// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface IVotingSystem2 {
    // Events
    event ProposalCreated(uint256 proposalId, address indexed proposer, string title);
    event VoteCast(uint256 proposalId, address indexed voter, bool support);
    event AGMVotingStarted();

    // View Functions
    function getProposal(uint256 proposalId)
        external
        view
        returns (
            address proposer,
            string memory title,
            string memory objectives,
            string memory background,
            string memory implementationPlan,
            string memory budget,
            uint256 dateCreated,
            uint256 votesFor,
            uint256 votesAgainst,
            uint8 status
        );


    // State-Changing Functions
    function createProposal(
        address proposer,
        string memory title,
        string memory objectives,
        string memory background,
        string memory implementationPlan,
        string memory budget
    ) external;

    function vote(uint256 proposalId, bool support) external;

    function startAGMVoting() external;
}
