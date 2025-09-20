const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const router = express.Router();
const User = require("../models/user.model");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

router.use(bodyParser.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const createReadingComprehensionPrompt = (passage, question, studentAnswer, correctAnswer) => {
  let prompt = `You are an English reading comprehension assistant. A student has read a passage and answered a comprehension question. Please analyze their response and provide feedback in a single paragraph format. Your response must be a JSON object with only one field.

  The response JSON must have the following structure:
  {
    "feedback": "<A single paragraph explaining the student's understanding and the correct answer>"
  }

  **Reading Passage:**
  "${passage}"

  **Question Asked:**
  "${question}"

  **Student's Answer:**
  "${studentAnswer}"

  **Correct Answer:**
  "${correctAnswer}"

  **Analysis Instructions:**
  1. Compare the student's answer with the correct answer
  2. If the student's answer is wrong or partially wrong, start with: "You have understood [explain their interpretation], but the actual answer would be [correct answer with explanation]"
  3. If the student's answer is correct, acknowledge what they understood correctly and reinforce the correct interpretation
  4. Stay strictly within the context of the given passage - do not assume or add any information not present in the passage
  5. Keep the language simple and appropriate for middle school students (class 8-10)
  6. Focus only on what the passage actually says, not on external knowledge
  7. The entire response should be one cohesive paragraph that flows naturally

  **Important Guidelines:**
  - Only use information explicitly mentioned in the passage
  - Do not make assumptions beyond what the passage states
  - Keep the explanation focused on the specific question asked
  - Use a conversational, encouraging tone
  - If the answer is partially correct, acknowledge the correct parts before explaining what needs correction
  `;

  return prompt;
};

// Helper function to extract JSON from markdown
const extractJsonFromMarkdown = (rawText) => {
  const jsonMatch = rawText.match(/```json\n(.*)\n```/s);
  if (jsonMatch && jsonMatch[1]) {
    return jsonMatch[1];
  }
  return rawText.trim();
};

router.post("/check-comprehension", async (req, res) => {
  try {
    const { passage, question, studentAnswer, correctAnswer } = req.body;

    // Validation
    if (!passage || !question || !studentAnswer || !correctAnswer) {
      return res.status(400).json({ 
        error: "Passage, question, studentAnswer, and correctAnswer are all required." 
      });
    }

    // Create the prompt for reading comprehension analysis
    const prompt = createReadingComprehensionPrompt(passage, question, studentAnswer, correctAnswer);
    
    // Get AI model and generate response
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent(prompt);
    const responseText = result.response.text();

    // Clean and parse the JSON response
    const cleanJsonText = extractJsonFromMarkdown(responseText);

    try {
      const analysis = JSON.parse(cleanJsonText);
      
      // Return the simplified response with just the feedback paragraph
      res.json({
        feedback: analysis.feedback || "Please review the passage and question again to better understand the context."
      });
    } catch (parseError) {
      console.error("JSON Parse Error:", parseError);
      res.status(500).json({ error: "Failed to parse AI response" });
    }
  } catch (error) {
    console.error("API Error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;