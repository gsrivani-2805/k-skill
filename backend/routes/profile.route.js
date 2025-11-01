const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const User = require("../models/user.model");

router.get("/:userId/profile", async (req, res) => {
  try {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid User ID format" });
    }

    const user = await User.findById(userId)
      .select(
        "name class gender school address currentStreak currentLevel completedLessons assessmentScores"
      )
      .lean();

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // ✅ Return all quiz fields properly
    const formattedCompletedLessons = (user.completedLessons || []).map(
      (lesson) => ({
        lessonId: lesson.lessonId,
        score: lesson.score ?? 0,
        totalQuestions: lesson.totalQuestions ?? 0,
        percentage: lesson.percentage ?? 0,
      })
    );

    const profileData = {
      name: user.name || "",
      class: user.class || "",
      gender: user.gender || "",
      school: user.school || "",
      address: user.address || "",
      currentStreak: user.currentStreak || 0,
      currentLevel: user.currentLevel || "Basic",
      completedLessons: formattedCompletedLessons, // ✅ Full lesson data
      assessmentScores: {
        quiz: user.assessmentScores?.quiz || 0,
        reading: user.assessmentScores?.reading || 0,
        listening: user.assessmentScores?.listening || 0,
        overall: user.assessmentScores?.overall || 0,
      },
    };

    res.json(profileData);
  } catch (error) {
    console.error("Error fetching user profile:", error);
    res.status(500).json({ error: "Internal Server Error" });
  }
});

router.put("/:userId/profile", async (req, res) => {
  try {
    const { userId } = req.params;
    const { name, class: className, school, address } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid User ID format" });
    }

    if (!name || !className || !school) {
      return res.status(400).json({
        error: "Missing required fields",
        required: ["name", "class", "school"],
        received: Object.keys(req.body),
      });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    user.name = name.trim();
    user.class = className.trim();
    user.school = school.trim();
    if (address) user.address = address.trim();

    const updatedUser = await user.save();

    const formattedCompletedLessons = (updatedUser.completedLessons || []).map(
      (lesson) => ({
        lessonId: lesson.lessonId,
        score: lesson.score ?? 0,
        totalQuestions: lesson.totalQuestions ?? 0,
        percentage: lesson.percentage ?? 0,
      })
    );

    const profileData = {
      name: updatedUser.name,
      class: updatedUser.class,
      gender: updatedUser.gender || "",
      school: updatedUser.school,
      address: updatedUser.address || "",
      currentStreak: updatedUser.currentStreak || 0,
      currentLevel: updatedUser.currentLevel || "Basic",
      completedLessons: formattedCompletedLessons, // ✅ return all fields
      assessmentScores: {
        ...updatedUser.assessmentScores,
        overall: updatedUser.assessmentScores?.overall || 0,
      },
    };

    res.json({
      message: "Profile updated successfully",
      profile: profileData,
    });
  } catch (error) {
    console.error("Error updating profile:", error);
    res
      .status(500)
      .json({ error: "Internal Server Error", details: error.message });
  }
});

router.post("/:userId/mark-complete", async (req, res) => {
  const { userId } = req.params;
  const { lessonId, quizScore, totalQuestions, percentage } = req.body;

  if (!lessonId || quizScore === undefined || totalQuestions === undefined) {
    return res.status(400).json({ message: "Missing required fields" });
  }

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    const existingLesson = user.completedLessons.find(
      (l) => l.lessonId === lessonId
    );

    if (existingLesson) {
      existingLesson.score = quizScore;
      existingLesson.totalQuestions = totalQuestions;
      existingLesson.percentage = percentage;
    } else {
      user.completedLessons.push({
        lessonId,
        score: quizScore,
        totalQuestions,
        percentage,
      });
    }

    await user.save();

    res.status(200).json({
      message: "Lesson marked complete",
      completedLessons: user.completedLessons,
    });
  } catch (error) {
    console.error("Error marking lesson complete:", error);
    res.status(500).json({ message: "Server error", error: error.message });
  }
});

router.post("/:userId/submit-assessment", async (req, res) => {
  const { userId } = req.params;
  const { quizScore, readingScore, listeningScore, overallScore } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    user.assessmentScores = {
      quiz: quizScore,
      reading: readingScore,
      listening: listeningScore,
      overall: overallScore,
    };

    if (overallScore >= 80) user.currentLevel = "Advanced";
    else if (overallScore >= 60) user.currentLevel = "Intermediate";
    else user.currentLevel = "Basic";

    await user.save();

    res.status(200).json({ message: "Assessment submitted successfully" });
  } catch (error) {
    console.error("Error submitting assessment:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});

router.post("/:userId/submissions", async (req, res) => {
  try {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      console.log("Invalid User ID format:", userId);
      return res.status(400).json({ error: "Invalid User ID format" });
    }

    const { discourseType, question, submittedText, feedback } = req.body;

    const missingFields = [];
    if (!discourseType) missingFields.push("discourseType");
    if (!submittedText) missingFields.push("submittedText");
    if (!feedback) missingFields.push("feedback");

    if (missingFields.length > 0) {
      console.log("Missing fields:", missingFields);
      return res.status(400).json({
        error: `Missing required fields: ${missingFields.join(", ")}`,
        receivedFields: Object.keys(req.body),
      });
    }

    console.log("All required fields present, finding user...");

    const user = await User.findById(userId);
    if (!user) {
      console.log("User not found for ID:", userId);
      return res.status(404).json({ error: "User not found" });
    }

    console.log("User found:", user.name || user.email);

    // Enhanced feedback mapping with validation
    let mappedFeedback;
    try {
      mappedFeedback = mapAIResponseToSchema(feedback);
      console.log("Mapped feedback:", JSON.stringify(mappedFeedback, null, 2));
    } catch (mappingError) {
      console.error("Error mapping feedback:", mappingError);
      // Use raw feedback if mapping fails
      mappedFeedback = feedback;
    }

    const newSubmission = {
      discourseType: discourseType.toString(),
      question: question || "",
      submittedText: submittedText.toString(),
      feedback: mappedFeedback,
      submissionDate: new Date(),
    };

    console.log(
      "Prepared submission for saving:",
      JSON.stringify(newSubmission, null, 2)
    );

    // Initialize writingSubmissions array if it doesn't exist
    if (!user.writingSubmissions) {
      console.log("Initializing writingSubmissions array");
      user.writingSubmissions = [];
    }

    // Add the new submission
    user.writingSubmissions.push(newSubmission);
    console.log(
      "Added submission, total submissions:",
      user.writingSubmissions.length
    );

    // Save with error handling
    const savedUser = await user.save();
    console.log(
      "User saved successfully, final submission count:",
      savedUser.writingSubmissions.length
    );

    res.status(201).json({
      message: "Writing submission saved successfully",
      submission: newSubmission,
      totalSubmissions: savedUser.writingSubmissions.length,
    });
  } catch (error) {
    if (error.name === "CastError") {
      return res.status(400).json({
        error: "Invalid User ID format",
        details: error.message,
      });
    }

    if (error.name === "ValidationError") {
      console.error("Validation errors:", error.errors);
      const validationErrors = Object.keys(error.errors).map((key) => ({
        field: key,
        message: error.errors[key].message,
        value: error.errors[key].value,
      }));
      return res.status(400).json({
        error: "Validation failed",
        details: validationErrors,
      });
    }

    res.status(500).json({
      error: "Internal Server Error",
      details: error.message,
      stack: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
});

function mapAIResponseToSchema(feedback) {
  console.log("Mapping feedback to schema:", typeof feedback, feedback);

  try {
    if (typeof feedback === "object" && feedback !== null) {
      return {
        overallScore: feedback.overallScore || feedback.score || 0,
        overallFeedback: feedback.overallFeedback || feedback.feedback || "",
        criteria: feedback.criteria || {},
        suggestions: feedback.suggestions || [],
        strengths: feedback.strengths || [],
        areasForImprovement:
          feedback.areasForImprovement || feedback.areas_for_improvement || [],
        ...feedback,
      };
    }

    if (typeof feedback === "string") {
      return {
        overallScore: 0,
        overallFeedback: feedback,
        criteria: {},
        suggestions: [],
        strengths: [],
        areasForImprovement: [],
      };
    }

    // Fallback for any other type
    return {
      overallScore: 0,
      overallFeedback: String(feedback),
      criteria: {},
      suggestions: [],
      strengths: [],
      areasForImprovement: [],
    };
  } catch (error) {
    return {
      overallScore: 0,
      overallFeedback: "Error processing feedback",
      criteria: {},
      suggestions: [],
      strengths: [],
      areasForImprovement: [],
    };
  }
}

router.get("/:userId/submissions", async (req, res) => {
  try {
    const { userId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid User ID format" });
    }

    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Get writing submissions with optional filtering and sorting
    const {
      limit = 50,
      offset = 0,
      discourseType,
      sortBy = "submissionDate",
      sortOrder = "desc",
    } = req.query;

    let submissions = user.writingSubmissions || [];

    // Filter by discourse type if specified
    if (discourseType) {
      submissions = submissions.filter(
        (sub) =>
          sub.discourseType?.toLowerCase() === discourseType.toLowerCase()
      );
    }

    // Sort submissions
    submissions.sort((a, b) => {
      let aValue = a[sortBy];
      let bValue = b[sortBy];

      if (sortBy === "submissionDate") {
        aValue = new Date(aValue);
        bValue = new Date(bValue);
      }

      if (sortOrder === "desc") {
        return bValue > aValue ? 1 : bValue < aValue ? -1 : 0;
      } else {
        return aValue > bValue ? 1 : aValue < bValue ? -1 : 0;
      }
    });

    // Apply pagination
    const totalSubmissions = submissions.length;
    const paginatedSubmissions = submissions.slice(
      parseInt(offset),
      parseInt(offset) + parseInt(limit)
    );

    // Format submissions for response
    const formattedSubmissions = paginatedSubmissions.map((submission) => ({
      id: submission._id,
      discourseType: submission.discourseType,
      question: submission.question,
      submittedText: submission.submittedText,
      feedback: submission.feedback,
      submissionDate: submission.submissionDate,
      // Add computed fields
      wordCount: submission.submittedText?.split(/\s+/).length || 0,
      overallScore:
        submission.feedback?.overallScore || submission.feedback?.score || 0,
    }));

    res.json({
      success: true,
      data: {
        submissions: formattedSubmissions,
        pagination: {
          total: totalSubmissions,
          limit: parseInt(limit),
          offset: parseInt(offset),
          hasMore: parseInt(offset) + parseInt(limit) < totalSubmissions,
        },
        filters: {
          discourseType: discourseType || null,
          sortBy,
          sortOrder,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      error: "Internal Server Error",
      details: error.message,
      stack: process.env.NODE_ENV === "development" ? error.stack : undefined,
    });
  }
});

router.post("/:userId/active-time", async (req, res) => {
  try {
    const { userId } = req.params;
    const { activeTime } = req.body;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid User ID" });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    if (!user.usageStats) {
      user.usageStats = { totalSeconds: 0, lastUpdated: new Date() };
    }

    const additionalSeconds = Number(activeTime) || 0;
    user.usageStats.totalSeconds += additionalSeconds;

    user.usageStats.lastUpdated = new Date();

    await user.save();

    res.json({
      message: "Active time updated successfully",
      usageStats: user.usageStats,
    });
  } catch (error) {
    console.error("Error updating active time:", error);
    res.status(500).json({ error: "Failed to update usage time" });
  }
});


module.exports = router;
