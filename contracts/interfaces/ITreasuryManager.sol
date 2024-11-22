// defines the contract interface
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ITreasuryManager {
    // Events
    event FundsReceived(address indexed from, uint256 amount);
    event FundsDisbursed(address indexed to, uint256 amount, uint256 proposalId);
    event FeeCollected(address indexed unit, uint256 amount, bool success);

    // View Functions
    function getBalance() external view returns (uint256);

    // State-Changing Functions
    function disburseFunds(address payable to, uint256 amount, uint256 proposalId) external;
    function collectManagementFees(address[] calldata units) external;
}
