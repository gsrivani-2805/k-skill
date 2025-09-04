const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const router = express.Router();
const User = require("../models/user.model");
const { GoogleGenerativeAI } = require("@google/generative-ai");
require("dotenv").config();

router.use(bodyParser.json());

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

const createDiscoursePrompt = (discourseType, text, question) => {
  let prompt = `You are an English writing assistant. A student has submitted a piece of writing. Please analyze it based on the specified discourse type and provide detailed feedback. Your response must be a single JSON object.

  The response JSON must have the following keys:
  "overall_score": "<number from 1 to 100>",
  "feedback_summary": "<A short summary of the feedback, max 30 words in a simple way that is understandable by the class 8, 9 and 10th students>",
  "errors": [
      {
          "type": "<e.g., Grammar, Punctuation, Structure, Vocabulary>",
          "description": "<detailed description of the error in simple words in a simple way that is understandable by the class 8, 9 and 10th students>",
          "suggestion": "<a clear suggestion for improvement in a simple way that is understandable by the class 8, 9 and 10th students>"
      }
  ],
  "discourse_specific_analysis": "<Analysis based on the type, e.g., 'The email successfully used a formal tone but lacked a clear call to action' in a simple way that is understandable by the class 8, 9 and 10th students'>",
  "final_suggestion": "<One actionable tip for the student, max 20 words in a simple way that is understandable by the class 8, 9 and 10th students>"
  `;

  if (question) {
    prompt += `\n\nThe student was asked to respond to the following question or prompt:\n"${question}"`;
    prompt += `\n\nYour analysis should also evaluate how well the writing answers the question or fulfills the prompt's requirements.`;
  }

  switch (discourseType.toLowerCase()) {
    case "email":
      prompt += `\n\nFor an email, focus your analysis on:
          - **Tone:** Is it formal or informal, as appropriate?
          - **Clarity:** Is the purpose of the email clear?
          - **Structure:** Does it have a proper subject line, salutation, body, and closing?
          - **Conciseness:** Is the message efficient?`;
      break;
    case "essay":
      prompt += `\n\nFor an essay, focus your analysis on:
          - **Thesis Statement:** Is there a clear central argument?
          - **Argumentation:** Is the reasoning logical and are supporting examples provided?
          - **Paragraph Structure:** Does each paragraph have a topic sentence and good flow?
          - **Cohesion and Coherence:** Do sentences and paragraphs connect smoothly?
          - **Vocabulary:** Is a varied and academic vocabulary used?`;
      break;
    case "cv":
      prompt += `\n\nFor a CV (Curriculum Vitae), focus on:
          - **Formatting:** Is it professional, clean, and easy to read?
          - **Relevance:** Is the information relevant to a job application?
          - **Action Verbs:** Are strong action verbs used?
          - **Conciseness:** Is the information brief and impactful?`;
      break;
    case "diary":
      prompt += `\n\nFor a diary entry, focus on:
          - **Personal Tone:** Is it informal and reflective?
          - **Narrative Flow:** Does it tell a story or describe events in a chronological or logical way?
          - **Emotional Expression:** Does it effectively convey thoughts and feelings?
          - **Grammar/Punctuation:** Note any major errors, but be aware of the informal style.`;
      break;
    case "letter":
      prompt += `\n\nFor a letter, focus on:
          - **Format:** Does it follow the correct format (e.g., addresses, date, salutation, closing)?
          - **Tone:** Is the tone appropriate (formal/informal) for the recipient?
          - **Clarity:** Is the purpose of the letter clear?`;
      break;
    case "speech":
      prompt += `\n\nFor a speech, focus on:
          - **Audience:** Is the language and tone appropriate for the intended audience?
          - **Rhetorical Devices:** Does it use techniques like repetition, metaphors, or questions to engage the audience?
          - **Structure:** Does it have a clear introduction, main points, and a conclusion?
          - **Flow:** Is the speech easy to deliver and listen to?`;
      break;
    default:
      prompt += `\n\nFor this general text, analyze for:
          - **Grammar and Syntax:** Correct sentence structure and grammar.
          - **Punctuation:** Proper use of commas, periods, etc.
          - **Spelling:** Correct spelling throughout the text.
          - **Clarity:** Is the text easy to understand?`;
      break;
  }

  prompt += `\n\nHere is the student's writing:\n"${text}"`;
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

// Helper function to map AI response fields to database schema fields
const mapAIResponseToSchema = (aiResponse) => {
  const mappedResponse = {
    overallScore: aiResponse.overall_score || aiResponse.overallScore || 0,
    feedbackSummary:
      aiResponse.feedback_summary ||
      aiResponse.feedbackSummary ||
      "No feedback summary available",
    discourseSpecificAnalysis:
      aiResponse.discourse_specific_analysis ||
      aiResponse.discourseSpecificAnalysis ||
      "No detailed analysis available",
    finalSuggestion:
      aiResponse.final_suggestion ||
      aiResponse.finalSuggestion ||
      "Keep practicing to improve your writing skills!",
    errors: aiResponse.errors || [],
  };

  // Ensure overallScore is a number
  if (typeof mappedResponse.overallScore === "string") {
    mappedResponse.overallScore = parseInt(mappedResponse.overallScore) || 0;
  }

  // Ensure all string fields are strings
  mappedResponse.feedbackSummary = String(mappedResponse.feedbackSummary);
  mappedResponse.discourseSpecificAnalysis = String(
    mappedResponse.discourseSpecificAnalysis
  );
  mappedResponse.finalSuggestion = String(mappedResponse.finalSuggestion);

  return mappedResponse;
};

router.post("/check-writing", async (req, res) => {
  try {
    const { text, discourseType, question } = req.body;

    if (!text || !discourseType) {
      return res
        .status(400)
        .json({ error: "Text, question and discourseType are required." });
    }

    const prompt = createDiscoursePrompt(discourseType, text, question);
    const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });
    const result = await model.generateContent(prompt);
    const responseText = result.response.text();

    const cleanJsonText = extractJsonFromMarkdown(responseText);

    try {
      const analysis = JSON.parse(cleanJsonText);

      // Map the AI response fields to match the database schema
      const mappedAnalysis = mapAIResponseToSchema(analysis);

      res.json(mappedAnalysis);
    } catch (parseError) {
      res.status(500).json({ error: "Failed to parse AI response" });
    }
  } catch (error) {
    res.status(500).json({ error: "Internal server error" });
  }
});

module.exports = router;
