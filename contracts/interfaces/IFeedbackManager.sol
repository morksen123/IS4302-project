// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "../types/DataTypes.sol";

interface IFeedbackManager {
    event FeedbackRaised(uint256 indexed feedbackId, address indexed unitAddress, string feedbackText);
    event FeedbackStatusUpdated(uint256 indexed feedbackId, DataTypes.FeedbackStatus newStatus);

    function raiseFeedback(string calldata feedbackText) external;
    function updateFeedbackStatus(uint256 feedbackId, DataTypes.FeedbackStatus newStatus) external;
    function getFeedback(uint256 feedbackId) external view returns (DataTypes.Feedback memory);
}
