// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IUnitManager.sol";
import "../interfaces/ITreasuryManager.sol";
import "../storage/TreasuryStorage.sol";
import "../storage/ProposalStorage.sol";

contract TreasuryManager is ITreasuryManager {
    address private owner;
    TreasuryStorage private treasuryStorage;
    ProposalStorage private proposalStorage;
    IUnitManager private unitManager;
    uint256 private constant COLLECTION_INTERVAL = 30 days;
    mapping(address => uint256) private lastCollectionTime;

    constructor(
        address treasuryStorageAddress,
        address proposalStorageAddress,
        address unitManagerAddress
    ) {
        require(treasuryStorageAddress != address(0), "Invalid treasury storage address");
        require(proposalStorageAddress != address(0), "Invalid proposal storage address");
        require(unitManagerAddress != address(0), "Invalid unit manager address");

        treasuryStorage = TreasuryStorage(treasuryStorageAddress);
        proposalStorage = ProposalStorage(proposalStorageAddress);
        unitManager = IUnitManager(unitManagerAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // View Functions
    function getBalance() external view returns (uint256) {
        return address(this).balance;
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
            proposalStorage.getProposal(proposalId).status == DataTypes.ProposalStatus.Accepted,
            "Proposal must be accepted"
        );

        treasuryStorage.recordDisbursement(proposalId, amount);
        (bool success, ) = to.call{value: amount}("");
        require(success, "Transfer failed");

        emit FundsDisbursed(to, amount, proposalId);
    }

    // Function to receive ETH
    receive() external payable {
        require(msg.value > 0, "Cannot send 0 ETH");
        emit FundsReceived(msg.sender, msg.value);
    }

    // Collect management fees from all units
    function collectManagementFees(address[] calldata units) external onlyOwner {
        for (uint i = 0; i < units.length; i++) {
            address unit = units[i];
            if (block.timestamp >= lastCollectionTime[unit] + COLLECTION_INTERVAL) {
                uint256 fee = unitManager.getManagementFee(unit);
                require(fee > 0, "No fee due");

                // Record collection time
                lastCollectionTime[unit] = block.timestamp;

                // Try to collect the fee by calling payManagementFee
                try unitManager.payManagementFee{value: fee}() {
                    emit FeeCollected(unit, fee, true);
                } catch {
                    // If collection fails, record as unsuccessful
                    emit FeeCollected(unit, fee, false);
                }
            }
        }
    }
}
