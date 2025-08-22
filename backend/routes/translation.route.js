// server.js
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const router = express.Router();
require('dotenv').config();

// In-memory cache for translations (use Redis in production)
const translationCache = new Map();
const CACHE_EXPIRY = 24 * 60 * 60 * 1000; // 24 hours

// Rate limiting (basic implementation)
const requestCounts = new Map();
const RATE_LIMIT = 100; // requests per hour
const RATE_LIMIT_WINDOW = 60 * 60 * 1000; // 1 hour

// Middleware for basic rate limiting
const rateLimit = (req, res, next) => {
  const clientIP = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  
  if (!requestCounts.has(clientIP)) {
    requestCounts.set(clientIP, { count: 1, windowStart: now });
    return next();
  }
  
  const clientData = requestCounts.get(clientIP);
  
  if (now - clientData.windowStart > RATE_LIMIT_WINDOW) {
    // Reset window
    requestCounts.set(clientIP, { count: 1, windowStart: now });
    return next();
  }
  
  if (clientData.count >= RATE_LIMIT) {
    return res.status(429).json({ 
      error: 'Rate limit exceeded. Please try again later.' 
    });
  }
  
  clientData.count++;
  next();
};

// Helper function to check cache
const getCachedTranslation = (text, targetLang) => {
  const key = `${text.toLowerCase()}_${targetLang}`;
  const cached = translationCache.get(key);
  
  if (cached && (Date.now() - cached.timestamp) < CACHE_EXPIRY) {
    return cached.translation;
  }
  
  return null;
};

// Helper function to set cache
const setCachedTranslation = (text, targetLang, translation) => {
  const key = `${text.toLowerCase()}_${targetLang}`;
  translationCache.set(key, {
    translation,
    timestamp: Date.now()
  });
};

// OpenAI GPT Integration
async function translateWithOpenAI(text, targetLanguage, context = null) {
  try {
    const prompt = context 
      ? `Given this context: "${context}"\n\nTranslate and explain the meaning of "${text}" in ${targetLanguage}. Provide both the translation and a brief explanation of its meaning in the context.`
      : `Translate "${text}" to ${targetLanguage} and provide a brief explanation of its meaning.`;

    const response = await axios.post(
      'https://api.openai.com/v1/chat/completions',
      {
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: `You are a helpful language tutor. Provide clear, concise translations and explanations suitable for language learners.`
          },
          {
            role: 'user',
            content: prompt
          }
        ],
        max_tokens: 200,
        temperature: 0.3,
      },
      {
        headers: {
          'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
          'Content-Type': 'application/json',
        },
      }
    );

    return response.data.choices[0].message.content.trim();
  } catch (error) {
    console.error('OpenAI API Error:', error.response?.data || error.message);
    
    // Check for quota exceeded error
    if (error.response?.data?.error?.code === 'insufficient_quota') {
      const quotaError = new Error('OpenAI quota exceeded');
      quotaError.code = 'insufficient_quota';
      throw quotaError;
    }
    
    throw new Error('OpenAI translation service temporarily unavailable');
  }
}

// Gemini API Integration
async function translateWithGemini(text, targetLanguage, context = null) {
  try {
    const prompt = context 
      ? `Given this context: "${context}"\n\nTranslate and explain the meaning of "${text}" in ${targetLanguage}. Provide both the translation and a brief explanation of its meaning in the context.`
      : `Translate "${text}" to ${targetLanguage} and provide a brief explanation of its meaning.`;

    const response = await axios.post(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=${process.env.GEMINI_API_KEY}`,
      {
        contents: [
          {
            parts: [
              {
                text: `You are a helpful language tutor. Provide clear, concise translations and explanations suitable for language learners.\n\n${prompt}`
              }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.3,
          maxOutputTokens: 200,
        }
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
      }
    );

    if (response.data?.candidates?.[0]?.content?.parts?.[0]?.text) {
      return response.data.candidates[0].content.parts[0].text.trim();
    } else {
      throw new Error('Invalid response format from Gemini API');
    }
  } catch (error) {
    console.error('Gemini API Error:', error.response?.data || error.message);
    throw new Error('Gemini translation service temporarily unavailable');
  }
}

// Google Translate API Integration (Alternative)
async function getTranslationFromGoogle(text, targetLanguage) {
  try {
    const response = await axios.post(
      `https://translation.googleapis.com/language/translate/v2?key=${process.env.GOOGLE_TRANSLATE_API_KEY}`,
      {
        q: text,
        target: targetLanguage,
        source: 'en', // or 'auto' for auto-detection
        format: 'text'
      }
    );

    const translation = response.data.data.translations[0].translatedText;
    
    // For better learning experience, add explanation using available AI service
    let explanation;
    try {
      explanation = await translateWithOpenAI(text, targetLanguage, `Translation: ${translation}`);
    } catch (openAIError) {
      try {
        explanation = await translateWithGemini(text, targetLanguage, `Translation: ${translation}`);
      } catch (geminiError) {
        explanation = `Translation: ${translation}`;
      }
    }
    
    return explanation;
  } catch (error) {
    console.error('Google Translate API Error:', error.response?.data || error.message);
    throw new Error('Translation service temporarily unavailable');
  }
}

// Unified function (tries OpenAI first, then Gemini)
async function getMeaning(text, targetLanguage = "en", context = null) {
  try {
    return await translateWithOpenAI(text, targetLanguage, context);
  } catch (err) {
    // Detect quota error explicitly
    if (err?.code === "insufficient_quota" || err?.message?.includes("quota")) {
      console.warn("OpenAI quota exceeded, switching to Gemini...");
    } else {
      console.warn("OpenAI failed, switching to Gemini...");
    }

    try {
      return await translateWithGemini(text, targetLanguage, context);
    } catch (err2) {
      console.error("Both OpenAI & Gemini failed:", err2.message);
      throw new Error("Translation service temporarily unavailable");
    }
  }
}

// Basic translation endpoint
router.post('/api/getMeaning', rateLimit, async (req, res) => {
  try {
    const { text, targetLanguage = 'telugu', context } = req.body;

    // Validation
    if (!text || text.trim().length === 0) {
      return res.status(400).json({ 
        error: 'Text is required and cannot be empty' 
      });
    }

    if (text.length > 500) {
      return res.status(400).json({ 
        error: 'Text too long. Maximum 500 characters allowed.' 
      });
    }

    // Check cache first
    const cachedResult = getCachedTranslation(text, targetLanguage);
    if (cachedResult) {
      return res.json({ 
        meaning: cachedResult,
        fromCache: true 
      });
    }

    // Get translation using unified function (OpenAI -> Gemini fallback)
    let meaning;
    if (process.env.USE_GOOGLE_TRANSLATE === 'true') {
      meaning = await getTranslationFromGoogle(text, targetLanguage);
    } else {
      meaning = await getMeaning(text, targetLanguage, context);
    }

    // Cache the result
    setCachedTranslation(text, targetLanguage, meaning);

    res.json({ 
      meaning,
      originalText: text,
      targetLanguage,
      fromCache: false
    });

  } catch (error) {
    console.error('Translation Error:', error.message);
    res.status(500).json({ 
      error: 'Translation service temporarily unavailable',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Contextual meaning endpoint for longer phrases
router.post('/api/getContextualMeaning', rateLimit, async (req, res) => {
  try {
    const { text, targetLanguage = 'tamil', fullContext, requestType } = req.body;

    if (!text || text.trim().length === 0) {
      return res.status(400).json({ 
        error: 'Text is required and cannot be empty' 
      });
    }

    // Use unified function for contextual meaning too
    const explanation = await getMeaning(text, targetLanguage, fullContext);

    res.json({ 
      explanation,
      originalText: text,
      context: fullContext,
      targetLanguage
    });

  } catch (error) {
    console.error('Contextual Translation Error:', error.message);
    res.status(500).json({ 
      error: 'Contextual meaning service temporarily unavailable' 
    });
  }
});

// Batch translation endpoint (for pre-loading common words)
router.post('/api/batchTranslate', rateLimit, async (req, res) => {
  try {
    const { texts, targetLanguage = 'tamil' } = req.body;

    if (!Array.isArray(texts) || texts.length === 0) {
      return res.status(400).json({ 
        error: 'Texts array is required and cannot be empty' 
      });
    }

    if (texts.length > 20) {
      return res.status(400).json({ 
        error: 'Maximum 20 texts allowed per batch' 
      });
    }

    const translations = {};
    const promises = texts.map(async (text) => {
      try {
        // Check cache first
        const cached = getCachedTranslation(text, targetLanguage);
        if (cached) {
          translations[text] = cached;
          return;
        }

        // Get new translation using unified function
        const meaning = await getMeaning(text, targetLanguage);
        translations[text] = meaning;
        setCachedTranslation(text, targetLanguage, meaning);
        
        // Add delay to avoid rate limiting
        await new Promise(resolve => setTimeout(resolve, 100));
      } catch (error) {
        translations[text] = `Error: ${error.message}`;
      }
    });

    await Promise.all(promises);

    res.json({ 
      translations,
      targetLanguage,
      totalProcessed: texts.length
    });

  } catch (error) {
    console.error('Batch Translation Error:', error.message);
    res.status(500).json({ 
      error: 'Batch translation service temporarily unavailable' 
    });
  }
});

// Get cache statistics (for monitoring)
router.get('/api/cache-stats', (req, res) => {
  const stats = {
    totalCachedItems: translationCache.size,
    cacheHitRate: '75%', // You can calculate this based on actual usage
    memoryUsage: process.memoryUsage(),
    uptime: process.uptime()
  };
  
  res.json(stats);
});

// Clear cache endpoint (for admin)
router.post('/api/clear-cache', (req, res) => {
  const { adminKey } = req.body;
  
  if (adminKey !== process.env.ADMIN_KEY) {
    return res.status(403).json({ error: 'Unauthorized' });
  }
  
  translationCache.clear();
  requestCounts.clear();
  
  res.json({ message: 'Cache cleared successfully' });
});

// Health check endpoint
router.get('/api/health', (req, res) => {
  res.json({ 
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

module.exports = router;