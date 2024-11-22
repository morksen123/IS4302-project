// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../types/DataTypes.sol";
import "./base/DataStorageBase.sol";

contract FeedbackStorage is DataStorageBase {
    DataTypes.Feedback[] private feedbacks;

    /// @notice Store new feedback and return its ID
    /// @param feedback The feedback to store
    /// @return feedbackId The ID of the newly stored feedback
    function storeFeedback(DataTypes.Feedback memory feedback) external onlyAuthorized returns (uint256) {
        feedbacks.push(feedback);
        return feedbacks.length - 1; // Return the ID of the newly stored feedback
    }

    /// @notice Retrieve feedback by its ID
    /// @param feedbackId The ID of the feedback to retrieve
    /// @return Feedback The feedback data
    function getFeedback(uint256 feedbackId) external view onlyAuthorized returns (DataTypes.Feedback memory) {
        require(feedbackId < feedbacks.length, "Invalid feedback ID");
        return feedbacks[feedbackId];
    }

    /// @notice Get the total count of feedbacks
    /// @return count The total number of feedbacks stored
    function getFeedbackCount() external view returns (uint256) {
        return feedbacks.length;
    }

    /// @notice Retrieve all feedback stored in the contract
    /// @return feedbacks Array of all feedbacks
    function getAllFeedback() external view onlyAuthorized returns (DataTypes.Feedback[] memory) {
        return feedbacks;
    }
}
