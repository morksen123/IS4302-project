// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../interfaces/IFeedbackManager.sol";
import "../storage/FeedbackStorage.sol";
import "../types/DataTypes.sol";

contract FeedbackManager is IFeedbackManager {
    FeedbackStorage private feedbackStorage;

    // Constructor accepts the address of FeedbackStorage
    constructor(address _feedbackStorage) public {
        feedbackStorage = FeedbackStorage(_feedbackStorage);
    }

    function raiseFeedback(string calldata feedbackText) external {
        DataTypes.Feedback memory newFeedback = DataTypes.Feedback({
            unitAddress: msg.sender,
            feedbackText: feedbackText,
            status: DataTypes.FeedbackStatus.Open,
            createdAt: block.timestamp
        });
        
        uint256 feedbackId = feedbackStorage.storeFeedback(newFeedback);
        emit FeedbackRaised(feedbackId, msg.sender, feedbackText);
    }

    function updateFeedbackStatus(uint256 feedbackId, DataTypes.FeedbackStatus newStatus) external {
        feedbackStorage.updateFeedbackStatus(feedbackId, newStatus);
        emit FeedbackStatusUpdated(feedbackId, newStatus);
    }

    function getFeedback(uint256 feedbackId) external view returns (DataTypes.Feedback memory) {
        return feedbackStorage.getFeedback(feedbackId);
    }

    // event FeedbackRaised(uint256 indexed feedbackId, address indexed unitAddress, string feedbackText);
    // event FeedbackStatusUpdated(uint256 indexed feedbackId, DataTypes.FeedbackStatus newStatus);
}