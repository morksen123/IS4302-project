// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "../types/DataTypes.sol";

interface IFeedbackManager {
    /// @notice Event emitted when feedback is submitted
    /// @param feedbackId The ID of the submitted feedback
    /// @param unitAddress The address of the unit that submitted the feedback
    /// @param feedbackText The content of the feedback
    event FeedbackSubmitted(uint256 indexed feedbackId, address indexed unitAddress, string feedbackText);

    /// @notice Submits feedback from the caller's unit
    /// @param feedbackText The text of the feedback
    function submitFeedback(string calldata feedbackText) external;

    /// @notice Retrieves feedback by ID
    /// @param feedbackId The ID of the feedback to retrieve
    function getFeedback(uint256 feedbackId)
        external
        view
        returns (
            address unitAddress,
            string memory feedbackText,
            uint256 createdAt
        );

    /// @notice Retrieves all feedback stored in the system
    function getAllFeedback()
        external
        view
        returns (
            address[] memory unitAddresses,
            string[] memory feedbackTexts,
            uint256[] memory createdAts
        );
}
