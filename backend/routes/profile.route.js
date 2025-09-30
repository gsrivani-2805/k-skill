// server.js or routes/user.js
const express = require("express");
const router = express.Router();
const mongoose = require("mongoose");
const User = require("../models/user.model");

// GET user profile by ID
router.get("/:userId/profile", async (req, res) => {
  try {
    const { userId } = req.params;

    const user = await User.findById(userId)
      .select(
        "name class gender school address currentStreak currentLevel completedLessons assessmentScores"
      )
      .lean();

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Format data as expected by Flutter
    const profileData = {
      name: user.name,
      class: user.class || "",
      gender: user.gender || "",
      school: user.school || "",
      address: user.address || "",
      currentStreak: user.currentStreak || 0,
      currentLevel: user.currentLevel || "Basic",
      completedLessons: user.completedLessons.map((lesson) => ({
        lessonId: lesson.lessonId,
      })),
      assessmentScores: {
        ...user.assessmentScores,
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

    // Validate User ID format
    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).json({ error: "Invalid User ID format" });
    }

    // Validate required fields
    if (!name || !className || !school) {
      return res.status(400).json({ 
        error: "Missing required fields", 
        required: ["name", "class", "school"],
        received: Object.keys(req.body)
      });
    }

    // Validate field lengths and formats
    if (name.length < 1 || name.length > 100) {
      return res.status(400).json({ error: "Name must be between 1 and 100 characters" });
    }
    if (className.length < 1 || className.length > 50) {
      return res.status(400).json({ error: "Class must be between 1 and 50 characters" });
    }
    if (school.length < 1 || school.length > 200) {
      return res.status(400).json({ error: "School name must be between 1 and 200 characters" });
    }

    // Find user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    // Store original values for potential rollback
    const originalValues = {
      name: user.name,
      class: user.class,
      school: user.school,
      address: user.address
    };

    try {
      // Update user fields
      user.name = name.trim();
      user.class = className.trim();
      user.school = school.trim();
      if (address) user.address = address.trim();

      // Save updated user
      const updatedUser = await user.save();

      // Return updated profile data in the same format as GET endpoint
      const profileData = {
        name: updatedUser.name,
        class: updatedUser.class,
        gender: updatedUser.gender || "",
        school: updatedUser.school,
        address: updatedUser.address || "",
        currentStreak: updatedUser.currentStreak || 0,
        currentLevel: updatedUser.currentLevel || "Basic",
        completedLessons: updatedUser.completedLessons.map((lesson) => ({
          lessonId: lesson.lessonId,
        })),
        assessmentScores: {
          ...updatedUser.assessmentScores,
          overall: updatedUser.assessmentScores?.overall || 0,
        },
      };

      res.json({
        message: "Profile updated successfully",
        profile: profileData,
        updatedFields: {
          name: updatedUser.name,
          class: updatedUser.class,
          school: updatedUser.school,
          address: updatedUser.address || ""
        }
      });

    } catch (saveError) {
      throw saveError;
    }

  } catch (error) {
    
    if (error.name === "ValidationError") {
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

    // Handle duplicate key errors
    if (error.code === 11000) {
      return res.status(400).json({
        error: "Duplicate value",
        details: "A user with this information already exists"
      });
    }

    // Handle cast errors
    if (error.name === "CastError") {
      return res.status(400).json({
        error: "Invalid data format",
        details: error.message
      });
    }

    // Generic server error
    res.status(500).json({ 
      error: "Internal Server Error",
      details: process.env.NODE_ENV === "development" ? error.message : "Something went wrong"
    });
  }
});

router.post("/:userId/mark-complete", async (req, res) => {
  try {
    const { userId } = req.params;
    const { lessonId, score = 0 } = req.body;

    if (!lessonId) {
      return res.status(400).json({ error: "lessonId is required" });
    }

    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ error: "User not found" });

    // Avoid duplicate entries
    const alreadyExists = user.completedLessons.some(
      (lesson) => lesson.lessonId === lessonId
    );

    if (!alreadyExists) {
      user.completedLessons.push({ lessonId, score });
      await user.save();
    }

    res.json({ message: "Lesson marked as completed" });
  } catch (error) {
    console.error("Error marking lesson complete:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

router.post("/:userId/submit-assessment", async (req, res) => {
  const { userId } = req.params;

  // Validate req.body exists
  if (!req.body) {
    return res.status(400).json({ message: "Missing request body" });
  }

  const { quizScore, readingScore, listeningScore, overallScore } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Initialize assessmentScores if undefined
    if (!user.assessmentScores) {
      user.assessmentScores = {};
    }

    // Assign scores
    user.assessmentScores.quiz = quizScore;
    user.assessmentScores.reading = readingScore;
    user.assessmentScores.listening = listeningScore;
    user.assessmentScores.overall = overallScore;

    if (overallScore >= 80) {
      user.currentLevel = "Advanced";
    } else if (overallScore >= 60) {
      user.currentLevel = "Intermediate";
    } else {
      user.currentLevel = "Basic";
    }

    await user.save();

    res.status(200).json({ message: "Assessment submitted successfully" });
  } catch (error) {
    console.error("Error submitting assessment:", error);
    res.status(500).json({ message: "Internal server error" });
  }
});
// Fixed backend route
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

module.exports = router;
