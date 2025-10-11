const express = require("express");
const router = express.Router();
const { GoogleGenerativeAI } = require("@google/generative-ai");
const lessons = require("./lessons");
require("dotenv").config();

// ✅ Ensure API key exists
if (!process.env.GEMINI_API_KEY) {
  console.error("❌ GEMINI_API_KEY is not set in .env");
}

// ✅ Initialize Gemini AI safely with fallback
let genAI, model;
try {
  genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

  // Use a supported model
  model = genAI.getGenerativeModel({ model: "gemini-1.5" });
  console.log("✅ Gemini model initialized: gemini-1.5");
} catch (error) {
  console.error("❌ Failed to initialize Gemini AI:", error.message);
}


// ✅ Build a structured prompt
function buildPrompt(userInput) {
  return `
You are a friendly and helpful English tutor chatbot for students in classes 4 to 8.
Your role is to assist students ONLY with English learning, including grammar, vocabulary,
writing, reading, and speaking skills.

Student Question: ${userInput}

Instructions for the chatbot:
- If the question is related to English learning, provide a simple, clear, and encouraging answer that helps the student understand and learn.
- If the question is NOT related to English, politely refuse to answer, e.g., say: "I'm sorry, I can only help with English learning questions."

Respond in a positive, student-friendly tone.
`;
}


// ✅ Generate AI response with retries
async function generateResponse(prompt, retries = 3) {
  try {
    const result = await model.generateContent(prompt);
    const text = result.response?.text() || "";

    if (!text.trim()) throw new Error("Empty response from Gemini AI");
    return text;
  } catch (err) {
    if (retries > 0 && err.message.includes("503")) {
      console.warn(`⚠️ Gemini overloaded, retrying... attempts left: ${retries}`);
      await new Promise(r => setTimeout(r, 2000));
      return generateResponse(prompt, retries - 1);
    }

    console.error("❌ AI error:", err);
    throw new Error("AI model error: " + err.message);
  }
}

// ✅ Keyword matching for lesson suggestions
function findRelevantLessons(message) {
  const lowerMsg = message.toLowerCase();
  return lessons
    .filter(lesson => lesson.keywords.some(kw => lowerMsg.includes(kw.toLowerCase())))
    .map(lesson => ({
      lessonId: lesson.lessonId,
      title: lesson.title,
      file_path: lesson.file_path,
    }));
}

// ✅ POST /chat endpoint
router.post("/chat", async (req, res) => {
  try {
    const { message } = req.body;

    if (!message || typeof message !== "string") {
      return res.status(400).json({ error: "Invalid message" });
    }

    const prompt = buildPrompt(message.trim());
    const aiResponse = await generateResponse(prompt);
    const relevantLessons = findRelevantLessons(message);

    return res.json({
      response: aiResponse,
      suggestions: relevantLessons,
    });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
});

module.exports = router;
