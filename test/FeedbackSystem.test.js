const FeedbackManager = artifacts.require("FeedbackManager");
const FeedbackStorage = artifacts.require("FeedbackStorage");

contract("FeedbackManager", (accounts) => {
  const [deployer, unit1, unit2] = accounts; // Sample accounts

  let feedbackManager, feedbackStorage;

  before(async () => {
    // Deploy the FeedbackStorage contract
    feedbackStorage = await FeedbackStorage.new();
    // Deploy the FeedbackManager contract with the storage contract address
    feedbackManager = await FeedbackManager.new(feedbackStorage.address);
  });

  it("should allow a unit to submit feedback", async () => {
    const feedbackText = "The community hall needs more chairs.";
    const tx = await feedbackManager.submitFeedback(feedbackText, { from: unit1 });

    // Verify that the FeedbackSubmitted event was emitted
    assert.equal(
      tx.logs[0].event,
      "FeedbackSubmitted",
      "FeedbackSubmitted event should be emitted"
    );
    assert.equal(tx.logs[0].args.unitAddress, unit1, "Feedback sender address should match");
    assert.equal(tx.logs[0].args.feedbackText, feedbackText, "Feedback text should match");

    // Retrieve feedback by ID and verify its details
    const feedback = await feedbackManager.getFeedback(0);
    assert.equal(feedback.unitAddress, unit1, "Stored feedback address should match the sender");
    assert.equal(feedback.feedbackText, feedbackText, "Stored feedback text should match");
  });

  it("should not allow empty feedback", async () => {
    try {
      await feedbackManager.submitFeedback("", { from: unit1 });
      assert.fail("Empty feedback should not be allowed");
    } catch (error) {
      assert(
        error.message.includes("Feedback text cannot be empty"),
        "Expected error for empty feedback"
      );
    }
  });

  it("should allow retrieving all feedback", async () => {
    // Submit multiple feedbacks
    await feedbackManager.submitFeedback("Great maintenance of the swimming pool!", {
      from: unit1,
    });
    await feedbackManager.submitFeedback("Request for additional parking spaces.", { from: unit2 });

    // Retrieve all feedback
    const feedbacks = await feedbackManager.getAllFeedback();

    const unitAddresses = feedbacks[0];
    const feedbackTexts = feedbacks[1];
    const createdAts = feedbacks[2];

    // Verify the length and details of feedback
    assert.equal(unitAddresses.length, 3, "There should be 3 feedbacks in total");
    assert.equal(
      feedbackTexts[1],
      "Great maintenance of the swimming pool!",
      "Second feedback text should match"
    );
    assert.equal(
      feedbackTexts[2],
      "Request for additional parking spaces.",
      "Third feedback text should match"
    );
    assert.equal(
      unitAddresses[2],
      unit2,
      "Third feedback should be submitted by the correct address"
    );
    assert.isAbove(parseInt(createdAts[2]), 0, "CreatedAt timestamp should be valid");
  });
});
