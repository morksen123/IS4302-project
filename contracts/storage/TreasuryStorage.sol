// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "./base/DataStorageBase.sol";

contract TreasuryStorage is DataStorageBase {
    // Storage
    mapping(uint256 => uint256) private proposalDisbursements;

    // Getters
    function getProposalDisbursement(
        uint256 proposalId
    ) external view onlyAuthorized returns (uint256) {
        return proposalDisbursements[proposalId];
    }

    // Setters
    function recordDisbursement(uint256 proposalId, uint256 amount) external onlyAuthorized {
        proposalDisbursements[proposalId] = amount;
    }
}
