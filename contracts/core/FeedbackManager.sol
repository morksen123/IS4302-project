// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IFeedbackManager.sol";
import "../storage/FeedbackStorage.sol";
import "../types/DataTypes.sol";

contract FeedbackManager is IFeedbackManager {
    FeedbackStorage private feedbackStorage;

    /// @notice Constructor initializes the contract with the address of FeedbackStorage
    /// @param _feedbackStorage The address of the deployed FeedbackStorage contract
    constructor(address _feedbackStorage) {
        require(_feedbackStorage != address(0), "Invalid FeedbackStorage address");
        feedbackStorage = FeedbackStorage(_feedbackStorage);
    }

    /// @notice Submits feedback from the caller's unit
    /// @param feedbackText The text of the feedback
    function submitFeedback(string calldata feedbackText) external override {
        require(bytes(feedbackText).length > 0, "Feedback text cannot be empty");

        DataTypes.Feedback memory feedback = DataTypes.Feedback({
            unitAddress: msg.sender,
            feedbackText: feedbackText,
            createdAt: block.timestamp
        });

        // Store feedback in FeedbackStorage
        uint256 feedbackId = feedbackStorage.storeFeedback(feedback);

        emit FeedbackSubmitted(feedbackId, msg.sender, feedbackText);
    
    }

    /// @notice Retrieves feedback by ID
    /// @param feedbackId The ID of the feedback to retrieve
    /// @return unitAddress The address of the unit that created the feedback
    /// @return feedbackText The text of the feedback
    /// @return createdAt The timestamp when the feedback was created
    function getFeedback(uint256 feedbackId)
        external
        view
        override
        returns (
            address unitAddress,
            string memory feedbackText,
            uint256 createdAt
        )
    {
        DataTypes.Feedback memory feedback = feedbackStorage.getFeedback(feedbackId);
        return (feedback.unitAddress, feedback.feedbackText, feedback.createdAt);
    }

    /// @notice Retrieves all feedback stored in the system
    /// @return unitAddresses Array of addresses that created feedback
    /// @return feedbackTexts Array of feedback texts
    /// @return createdAts Array of timestamps when feedback was created
    function getAllFeedback()
        external
        view
        override
        returns (
            address[] memory unitAddresses,
            string[] memory feedbackTexts,
            uint256[] memory createdAts
        )
    {
        DataTypes.Feedback[] memory feedbacks = feedbackStorage.getAllFeedback();
        uint256 feedbackCount = feedbacks.length;

        // Preallocate arrays to return
        unitAddresses = new address[](feedbackCount);
        feedbackTexts = new string[](feedbackCount);
        createdAts = new uint256[](feedbackCount);

        for (uint256 i = 0; i < feedbackCount; i++) {
            unitAddresses[i] = feedbacks[i].unitAddress;
            feedbackTexts[i] = feedbacks[i].feedbackText;
            createdAts[i] = feedbacks[i].createdAt;
        }

        return (unitAddresses, feedbackTexts, createdAts);
    }
}



 // function raiseFeedback(string calldata feedbackText) external {
    //     DataTypes.Feedback memory newFeedback = DataTypes.Feedback({
    //         unitAddress: msg.sender,
    //         feedbackText: feedbackText,
    //         status: DataTypes.FeedbackStatus.Open,
    //         createdAt: block.timestamp
    //     });
        
    //     uint256 feedbackId = feedbackStorage.storeFeedback(newFeedback);
    //     emit FeedbackRaised(feedbackId, msg.sender, feedbackText);
    // }

    // function updateFeedbackStatus(uint256 feedbackId, DataTypes.FeedbackStatus newStatus) external {
    //     feedbackStorage.updateFeedbackStatus(feedbackId, newStatus);
    //     emit FeedbackStatusUpdated(feedbackId, newStatus);
    // }

    // function getFeedback(uint256 feedbackId) external view returns (DataTypes.Feedback memory) {
    //     return feedbackStorage.getFeedback(feedbackId);
    // }

    // event FeedbackRaised(uint256 indexed feedbackId, address indexed unitAddress, string feedbackText);
    // event FeedbackStatusUpdated(uint256 indexed feedbackId, DataTypes.FeedbackStatus newStatus);