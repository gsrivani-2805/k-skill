// lib/services/translation_service.dart
import 'dart:convert';
import 'package:K_Skill/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TranslationService {
  static const String _baseUrl = ApiConfig.baseUrl; // Change to your actual API URL
  static const String _cacheKeyPrefix = 'translation_cache_';
  static const int _cacheExpiryHours = 24;

  // Singleton pattern
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Check network connectivity
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Get cached translation
  Future<String?> _getCachedTranslation(String text, String targetLanguage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix${text.toLowerCase()}_$targetLanguage';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final data = jsonDecode(cachedData);
        final timestamp = DateTime.parse(data['timestamp']);
        final now = DateTime.now();
        
        // Check if cache is still valid (24 hours)
        if (now.difference(timestamp).inHours < _cacheExpiryHours) {
          return data['translation'];
        } else {
          // Remove expired cache
          prefs.remove(cacheKey);
        }
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }

  // Set cached translation
  Future<void> _setCachedTranslation(String text, String targetLanguage, String translation) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cacheKeyPrefix${text.toLowerCase()}_$targetLanguage';
      final cacheData = {
        'translation': translation,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      print('Error setting cache: $e');
    }
  }

  // Get basic translation/meaning
  Future<TranslationResult> getMeaning(String text, {String targetLanguage = 'telugu'}) async {
    try {
      // Input validation
      if (text.trim().isEmpty) {
        return TranslationResult.error('Text cannot be empty');
      }

      if (text.length > 500) {
        return TranslationResult.error('Text too long. Maximum 500 characters allowed.');
      }

      // Check cache first
      final cachedTranslation = await _getCachedTranslation(text, targetLanguage);
      if (cachedTranslation != null) {
        return TranslationResult.success(cachedTranslation, fromCache: true);
      }

      // Check internet connectivity
      if (!await _hasInternetConnection()) {
        return TranslationResult.error('No internet connection. Please check your network and try again.');
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/getMeaning'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'targetLanguage': targetLanguage,
            }),
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meaning = data['meaning'] ?? 'No meaning found.';
        
        // Cache the result
        await _setCachedTranslation(text, targetLanguage, meaning);
        
        return TranslationResult.success(meaning, fromCache: false);
      } else if (response.statusCode == 429) {
        return TranslationResult.error('Too many requests. Please wait a moment and try again.');
      } else {
        final data = jsonDecode(response.body);
        return TranslationResult.error(data['error'] ?? 'Server error occurred');
      }
    } catch (e) {
      print('Translation error: $e');
      
      // Try to get cached version as fallback
      final cachedTranslation = await _getCachedTranslation(text, targetLanguage);
      if (cachedTranslation != null) {
        return TranslationResult.success(cachedTranslation, fromCache: true, isOffline: true);
      }
      
      return TranslationResult.error('Network error: ${e.toString()}');
    }
  }

  // Get contextual meaning for longer phrases
  Future<TranslationResult> getContextualMeaning(
    String text, 
    String fullContext, {
    String targetLanguage = 'telugu'
  }) async {
    try {
      if (text.trim().isEmpty) {
        return TranslationResult.error('Text cannot be empty');
      }

      if (!await _hasInternetConnection()) {
        return TranslationResult.error('No internet connection required for contextual translation.');
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/getContextualMeaning'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'text': text,
              'targetLanguage': targetLanguage,
              'fullContext': fullContext,
              'requestType': 'contextual',
            }),
          )
          .timeout(Duration(seconds: 45));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TranslationResult.success(data['explanation'] ?? 'No explanation found.');
      } else {
        final data = jsonDecode(response.body);
        return TranslationResult.error(data['error'] ?? 'Contextual translation failed');
      }
    } catch (e) {
      return TranslationResult.error('Error getting contextual meaning: ${e.toString()}');
    }
  }

  // Batch translate multiple texts (useful for pre-loading)
  Future<Map<String, String>> batchTranslate(
    List<String> texts, {
    String targetLanguage = 'telugu'
  }) async {
    final results = <String, String>{};
    
    try {
      if (!await _hasInternetConnection()) {
        throw Exception('No internet connection');
      }

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/batchTranslate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'texts': texts,
              'targetLanguage': targetLanguage,
            }),
          )
          .timeout(Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['translations'] as Map<String, dynamic>;
        
        // Cache each translation
        for (final entry in translations.entries) {
          results[entry.key] = entry.value.toString();
          await _setCachedTranslation(entry.key, targetLanguage, entry.value.toString());
        }
      }
    } catch (e) {
      print('Batch translation error: $e');
    }
    
    return results;
  }

  // Clear translation cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  // Get cache statistics
  Future<CacheStats> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKeys = prefs.getKeys().where((key) => key.startsWith(_cacheKeyPrefix));
      
      int validCacheCount = 0;
      int expiredCacheCount = 0;
      
      for (final key in cacheKeys) {
        final cachedData = prefs.getString(key);
        if (cachedData != null) {
          try {
            final data = jsonDecode(cachedData);
            final timestamp = DateTime.parse(data['timestamp']);
            final now = DateTime.now();
            
            if (now.difference(timestamp).inHours < _cacheExpiryHours) {
              validCacheCount++;
            } else {
              expiredCacheCount++;
            }
          } catch (e) {
            expiredCacheCount++;
          }
        }
      }
      
      return CacheStats(
        totalCached: validCacheCount,
        expired: expiredCacheCount,
      );
    } catch (e) {
      return CacheStats(totalCached: 0, expired: 0);
    }
  }
}

// Result classes
class TranslationResult {
  final bool success;
  final String message;
  final bool fromCache;
  final bool isOffline;

  TranslationResult._({
    required this.success,
    required this.message,
    this.fromCache = false,
    this.isOffline = false,
  });

  factory TranslationResult.success(String translation, {bool fromCache = false, bool isOffline = false}) {
    return TranslationResult._(
      success: true,
      message: translation,
      fromCache: fromCache,
      isOffline: isOffline,
    );
  }

  factory TranslationResult.error(String error) {
    return TranslationResult._(
      success: false,
      message: error,
    );
  }
}

class CacheStats {
  final int totalCached;
  final int expired;

  CacheStats({required this.totalCached, required this.expired});
}