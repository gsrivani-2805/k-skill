// routes/translation.route.js - Diagnostic Version
const express = require("express");
const router = express.Router();
const axios = require("axios");

// Helper functions and translation logic
const translationCache = new Map();
const MAX_CACHE_SIZE = 1000;
const CACHE_EXPIRY = 24 * 60 * 60 * 1000; // 24 hours

const getCachedTranslation = (text, targetLang) => {
  const key = `${text.toLowerCase().trim()}_${targetLang}`;
  const cached = translationCache.get(key);
  if (cached && Date.now() - cached.timestamp < CACHE_EXPIRY)
    return cached.translation;
  if (cached) translationCache.delete(key);
  return null;
};

const setCachedTranslation = (text, targetLang, translation) => {
  if (translationCache.size >= MAX_CACHE_SIZE) {
    const oldestKeys = Array.from(translationCache.keys()).slice(0, 100);
    oldestKeys.forEach((key) => translationCache.delete(key));
  }
  const key = `${text.toLowerCase().trim()}_${targetLang}`;
  translationCache.set(key, { translation, timestamp: Date.now() });
};

// Test API configuration
function checkAPIConfig() {
  const openaiConfigured = !!process.env.OPENAI_API_KEY;
  const geminiConfigured = !!process.env.GEMINI_API_KEY;
  
  console.log("=== API CONFIGURATION CHECK ===");
  console.log("OpenAI API Key configured:", openaiConfigured);
  console.log("Gemini API Key configured:", geminiConfigured);
  
  if (openaiConfigured) {
    console.log("OpenAI Key length:", process.env.OPENAI_API_KEY.length);
    console.log("OpenAI Key starts with:", process.env.OPENAI_API_KEY.substring(0, 8) + "...");
  }
  
  if (geminiConfigured) {
    console.log("Gemini Key length:", process.env.GEMINI_API_KEY.length);
    console.log("Gemini Key starts with:", process.env.GEMINI_API_KEY.substring(0, 8) + "...");
  }
  
  return { openaiConfigured, geminiConfigured };
}

// Simple working translation function for testing
async function testOpenAI(text, targetLanguage) {
  console.log("\n=== TESTING OPENAI ===");
  
  if (!process.env.OPENAI_API_KEY) {
    console.log("❌ OpenAI API key not found");
    return null;
  }

  try {
    // Very simple prompt that should work
    const prompt = `Translate "${text}" to ${targetLanguage}. Provide a simple explanation and translation.`;
    
    console.log("Sending request to OpenAI...");
    console.log("Prompt:", prompt);
    
    const response = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model: "gpt-3.5-turbo",
        messages: [
          { role: "user", content: prompt }
        ],
        max_tokens: 200,
        temperature: 0.3,
      },
      {
        headers: { 
          Authorization: `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json'
        },
        timeout: 15000,
      }
    );

    const result = response.data?.choices?.[0]?.message?.content?.trim();
    console.log("✅ OpenAI Response received:", result?.substring(0, 100) + "...");
    
    return {
      word: text,
      phonetic: "",
      definition: result || "No response from OpenAI",
      example: `Example with "${text}"`,
      telugu: targetLanguage === 'telugu' ? "Translation included above" : "",
      hindi: targetLanguage === 'hindi' ? "Translation included above" : "",
      type: "word",
      example_sentence_usage: `"${text}" can be used in sentences.`,
      example_sentence_translation: "Translation provided above",
      source: "OpenAI"
    };
    
  } catch (error) {
    console.log("❌ OpenAI Error:", error.message);
    console.log("Error details:", {
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data
    });
    return null;
  }
}

async function testGemini(text, targetLanguage) {
  console.log("\n=== TESTING GEMINI ===");
  
  if (!process.env.GEMINI_API_KEY) {
    console.log("❌ Gemini API key not found");
    return null;
  }

  try {
    // Very simple prompt
    const prompt = `Translate "${text}" to ${targetLanguage}. Provide explanation and translation.`;
    
    console.log("Sending request to Gemini...");
    console.log("Prompt:", prompt);
    
    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { 
          temperature: 0.3, 
          maxOutputTokens: 200
        },
      },
      { 
        timeout: 15000,
        headers: { 'Content-Type': 'application/json' }
      }
    );

    const result = response.data?.candidates?.[0]?.content?.parts?.[0]?.text?.trim();
    console.log("✅ Gemini Response received:", result?.substring(0, 100) + "...");
    
    return {
      word: text,
      phonetic: "",
      definition: result || "No response from Gemini",
      example: `Example with "${text}"`,
      telugu: targetLanguage === 'telugu' ? "Translation included above" : "",
      hindi: targetLanguage === 'hindi' ? "Translation included above" : "",
      type: "word", 
      example_sentence_usage: `"${text}" can be used in sentences.`,
      example_sentence_translation: "Translation provided above",
      source: "Gemini"
    };
    
  } catch (error) {
    console.log("❌ Gemini Error:", error.message);
    console.log("Error details:", {
      status: error.response?.status,
      statusText: error.response?.statusText,
      data: error.response?.data
    });
    return null;
  }
}

// Enhanced fallback
function getFallbackTranslation(text, targetLanguage) {
  console.log("\n=== USING FALLBACK ===");
  
  const commonTranslations = {
    hello: { telugu: "హలో", hindi: "नमस्ते", definition: "A greeting used when meeting someone" },
    "thank you": { telugu: "ధన్యవాదాలు", hindi: "धन्यवाद", definition: "Expression of gratitude" },
    good: { telugu: "మంచి", hindi: "अच्छा", definition: "Of high quality; satisfactory" },
    water: { telugu: "నీరు", hindi: "पानी", definition: "Colorless liquid essential for life" },
    food: { telugu: "ఆహారం", hindi: "भोजन", definition: "Substances consumed for nutrition" },
    tattered: { 
      telugu: "చిరిగిన", 
      hindi: "फटा हुआ", 
      definition: "Old and torn; in poor condition",
      phonetic: "/ˈtætəd/"
    },
    reluctantly: { 
      telugu: "అయిష్టంగా", 
      hindi: "अनिच्छा से", 
      definition: "In an unwilling or hesitant manner",
      phonetic: "/rɪˈlʌktəntli/"
    }
  };

  const lowerText = text.toLowerCase().trim();
  const translation = commonTranslations[lowerText];

  if (translation) {
    console.log("✅ Found in local dictionary:", lowerText);
    return {
      word: text,
      phonetic: translation.phonetic || "",
      definition: translation.definition,
      example: `Example: The ${lowerText} clothes were old and worn.`,
      telugu: translation.telugu || "",
      hindi: translation.hindi || "",
      type: "word",
      example_sentence_usage: `"The blanket was ${lowerText} and needed repair."`,
      example_sentence_translation: targetLanguage.toLowerCase() === 'telugu' ? 
        `దుప్పటి ${translation.telugu} మరియు మరమ్మత్తు అవసరం.` :
        `कंबल ${translation.hindi} था और मरम्मत की जरूरत थी।`,
      source: "Local Dictionary"
    };
  }
  
  console.log("❌ Word not found in local dictionary");
  return {
    word: text,
    phonetic: "",
    definition: `Word "${text}" - AI translation unavailable. Please check server logs for API issues.`,
    example: `This term "${text}" needs online translation.`,
    telugu: "",
    hindi: "",
    type: "unknown",
    example_sentence_usage: `"${text}" is used in context.`,
    example_sentence_translation: "Translation requires working AI service.",
    error: `AI services unavailable for "${text}"`,
    source: "Fallback"
  };
}

// Main translation function with detailed logging
async function getMeaning(text, targetLanguage = "telugu", context = null) {
  console.log(`\n🔍 STARTING TRANSLATION PROCESS`);
  console.log(`Text: "${text}"`);
  console.log(`Target Language: ${targetLanguage}`);
  console.log(`Context: ${context || "None"}`);
  
  // Check cache first
  const cached = getCachedTranslation(text, targetLanguage);
  if (cached) {
    console.log("✅ Found in cache");
    return { ...cached, source: "Cache" };
  }

  // Check API configuration
  const { openaiConfigured, geminiConfigured } = checkAPIConfig();

  // Try OpenAI
  if (openaiConfigured) {
    const openaiResult = await testOpenAI(text, targetLanguage);
    if (openaiResult) {
      setCachedTranslation(text, targetLanguage, openaiResult);
      return openaiResult;
    }
  }

  // Try Gemini  
  if (geminiConfigured) {
    const geminiResult = await testGemini(text, targetLanguage);
    if (geminiResult) {
      setCachedTranslation(text, targetLanguage, geminiResult);
      return geminiResult;
    }
  }

  // Use fallback
  const fallback = getFallbackTranslation(text, targetLanguage);
  setCachedTranslation(text, targetLanguage, fallback);
  return fallback;
}

// POST endpoint with comprehensive logging
router.post("/api/getMeaning", async (req, res) => {
  const startTime = Date.now();
  
  try {
    console.log("\n" + "=".repeat(50));
    console.log("📨 NEW TRANSLATION REQUEST");
    console.log("Time:", new Date().toISOString());
    console.log("Request body:", req.body);
    
    const { text, targetLanguage = "telugu", context } = req.body;
    
    if (!text || typeof text !== "string" || !text.trim()) {
      console.log("❌ Invalid text provided");
      return res.status(400).json({ 
        error: "Text is required",
        word: "",
        phonetic: "",
        definition: "No text provided for translation",
        example: "",
        telugu: "",
        hindi: "",
        type: "error",
        example_sentence_usage: "",
        example_sentence_translation: "",
        source: "Validation Error"
      });
    }

    const meaning = await getMeaning(text.trim(), targetLanguage, context);
    const duration = Date.now() - startTime;
    
    console.log(`\n✅ TRANSLATION COMPLETED in ${duration}ms`);
    console.log("Response:", {
      word: meaning.word,
      source: meaning.source,
      hasTranslation: !!(meaning.telugu || meaning.hindi)
    });
    console.log("=".repeat(50));
    
    res.json(meaning);
  } catch (err) {
    const duration = Date.now() - startTime;
    console.error(`\n❌ TRANSLATION FAILED after ${duration}ms`);
    console.error("Error:", err.message);
    console.error("Stack:", err.stack);
    
    res.status(500).json({ 
      word: req.body.text || "",
      phonetic: "",
      definition: "Server error occurred during translation",
      example: "",
      telugu: "",
      hindi: "",
      type: "error",
      example_sentence_usage: "",
      example_sentence_translation: "",
      error: "Translation failed", 
      message: err.message,
      source: "Error Handler"
    });
  }
});

// Health check endpoint
router.get("/api/health", (req, res) => {
  const { openaiConfigured, geminiConfigured } = checkAPIConfig();
  
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    apis: {
      openai: openaiConfigured,
      gemini: geminiConfigured
    },
    cacheSize: translationCache.size
  });
});

module.exports = router;