// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/ITreasuryManager.sol";
import "../storage/TreasuryStorage.sol";

contract TreasuryManager is ITreasuryManager {
    TreasuryStorage private treasuryStorage;
    address private owner;
    uint256 private constant INITIAL_MINIMUM_RESERVE = 10 ether; // Example: 10 ETH

    constructor(address storageAddress) {
        treasuryStorage = TreasuryStorage(storageAddress);
        owner = msg.sender;
        treasuryStorage.setMinimumReserve(INITIAL_MINIMUM_RESERVE);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // View Functions
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getMinimumReserve() external view returns (uint256) {
        return treasuryStorage.getMinimumReserve();
    }

    function getProposalBudget() external view returns (uint256) {
        uint256 availableFunds = address(this).balance;
        uint256 minimumReserve = treasuryStorage.getMinimumReserve();
        return availableFunds > minimumReserve ? availableFunds - minimumReserve : 0;
    }

    // State-Changing Functions
    function disburseFunds(
        address payable to,
        uint256 amount,
        uint256 proposalId
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(
            address(this).balance - amount >= treasuryStorage.getMinimumReserve(),
            "Insufficient funds above minimum reserve"
        );

        treasuryStorage.recordDisbursement(proposalId, amount);
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");

        emit FundsDisbursed(to, amount, proposalId);
    }

    function updateMinimumReserve(uint256 newReserve) external onlyOwner {
        require(newReserve > 0, "Minimum reserve must be greater than 0");
        treasuryStorage.setMinimumReserve(newReserve);
    }

    function emergencyWithdraw(address payable to, uint256 amount) external onlyOwner {
        require(to != address(0), "Invalid recipient address");
        require(amount > 0 && amount <= address(this).balance, "Invalid amount");

        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");

        emit EmergencyWithdrawal(to, amount);
    }

    // Function to receive ETH
    receive() external payable {
        require(msg.value > 0, "Cannot send 0 ETH");
        emit FundsReceived(msg.sender, msg.value);
    }
}
