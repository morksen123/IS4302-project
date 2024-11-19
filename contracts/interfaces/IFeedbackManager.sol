// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;
import "../types/DataTypes.sol";

interface IFeedbackManager {
    event FeedbackSubmitted(uint256 indexed feedbackId, address indexed unitAddress, string feedbackText);

    function submitFeedback(string calldata feedbackText) external;

    function getFeedback(uint256 feedbackId) external view returns (address unitAddress, string memory feedbackText, uint256 createdAt);

    function getAllFeedback() external view returns (address[] memory unitAddresses, string[] memory feedbackTexts, uint256[] memory createdAts);
}

