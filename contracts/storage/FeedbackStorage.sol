// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

import "../types/DataTypes.sol";
import "./base/DataStorageBase.sol";

contract FeedbackStorage is DataStorageBase  {
    DataTypes.Feedback[] private feedbacks;

    // Store new feedback and return its ID
    function storeFeedback(DataTypes.Feedback memory feedback) external returns (uint256) {
        feedbacks.push(feedback);
        return feedbacks.length - 1; // Return the ID of the newly stored feedback
    }

    // Retrieve feedback by its ID
    function getFeedback(uint256 feedbackId) external view returns (DataTypes.Feedback memory) {
        require(feedbackId < feedbacks.length, "Invalid feedback ID");
        return feedbacks[feedbackId];
    }

    // Update the status of feedback by its ID
    // function updateFeedbackStatus(uint256 feedbackId, DataTypes.FeedbackStatus newStatus) external {
    //     require(feedbackId < feedbacks.length, "Invalid feedback ID");
    //     feedbacks[feedbackId].status = newStatus;
    //  }

    // Get the total count of feedbacks
    function getFeedbackCount() external view returns (uint256) {
        return feedbacks.length;
        
    }

   /// @notice Retrieves all feedback stored in the contract
    /// @return Array of all feedbacks
    function getAllFeedback() external view returns (DataTypes.Feedback[] memory) {
        return feedbacks;
    }
}

  
