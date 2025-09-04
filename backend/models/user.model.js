const mongoose = require("mongoose");

const completedLessonSchema = new mongoose.Schema({
  lessonId: { type: String, required: true },
  score: { type: Number, required: true },
}, { _id: false });

const assessmentSchema = new mongoose.Schema({
  quiz: { type: Number, default: 0 },
  reading: { type: Number, default: 0 },
  listening: { type: Number, default: 0 },
  overall: { type: Number, default: 0 },
}, { _id: false });

// New Schema for individual errors within feedback
const WritingErrorSchema = new mongoose.Schema({
    type: String,
    description: String,
    suggestion: String,
}, { _id: false });

// New Schema for the entire feedback object
const FeedbackSchema = new mongoose.Schema({
    overallScore: { type: Number, required: true },
    feedbackSummary: { type: String, required: true },
    discourseSpecificAnalysis: { type: String, required: true },
    errors: [WritingErrorSchema],
    finalSuggestion: { type: String, required: true },
}, { _id: false });

// UPDATED writingSubmissionSchema to include the 'feedback' field
const writingSubmissionSchema = new mongoose.Schema({
  discourseType: { type: String, required: true },
  question: { type: String },
  submittedText: { type: String, required: true },
  submissionDate: { type: Date, default: Date.now },
  feedback: { type: FeedbackSchema, required: true }, 
}, { _id: false });

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  password: { type: String, required: true },

  class: { type: String },
  gender: { type: String, enum: ['Male', 'Female', 'Other'], default: 'Other' },
  school: { type: String },
  address: { type: String },

  currentStreak: { type: Number, default: 1 },
  lastLogin: { type: Date, default: Date.now },

  completedLessons: [completedLessonSchema],

  assessmentScores: assessmentSchema,

  // This will now store writing submissions with their full feedback
  writingSubmissions: [writingSubmissionSchema],

  currentLevel: {
    type: String,
    enum: ['Basic', 'Intermediate', 'Advanced'],
    default: 'Basic',
  },
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);