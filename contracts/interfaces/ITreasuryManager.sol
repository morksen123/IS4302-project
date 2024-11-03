// defines the contract interface
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

interface ITreasuryManager {
    // Events
    event FundsReceived(address indexed from, uint256 amount);
    event FundsDisbursed(address indexed to, uint256 amount, uint256 proposalId);
    event EmergencyWithdrawal(address indexed to, uint256 amount);
    
    // View Functions
    function getBalance() external view returns (uint256);
    function getMinimumReserve() external view returns (uint256);
    function getProposalBudget() external view returns (uint256);
    
    // State-Changing Functions
    function receiveFunds() external payable;
    function disburseFunds(address payable to, uint256 amount, uint256 proposalId) external;
    function updateMinimumReserve(uint256 newReserve) external;
    function emergencyWithdraw(address payable to, uint256 amount) external;
}
