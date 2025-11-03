import 'dart:convert';
import 'package:K_Skill/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const _baseUrl = ApiConfig.baseUrl;

  // USER ID
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // USER NAME
  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  // JWT TOKEN + LOGIN TIME
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Check token validity (24 hrs)
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString('loginTime');

    if (loginTimeStr == null) return false;

    final loginTime = DateTime.parse(loginTimeStr);
    final now = DateTime.now();

    if (now.difference(loginTime).inHours >= 24) {
      await logout();
      return false;
    }
    return true;
  }

  /// Add active time (in seconds)
  static Future<void> addActiveTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    double current = prefs.getDouble('totalUsageSeconds') ?? 0;
    current += seconds;
    await prefs.setDouble('totalUsageSeconds', current);
  }

  /// Get total usage time (in seconds)
  static Future<double> getActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('totalUsageSeconds') ?? 0;
  }

  /// Reset total usage time
  static Future<void> resetActiveTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalUsageSeconds', 0);
  }

  /// Sync usage time with server
  static Future<void> syncActiveTimeWithServer() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;

    if (userId == null || totalSeconds <= 0) {
      return;
    }

    try {

      final response = await http.post(
        Uri.parse("$_baseUrl/$userId/active-time"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"activeTime": totalSeconds.toInt()}),
      );

      if (response.statusCode == 200) {
        await prefs.setDouble('totalUsageSeconds', 0); // reset after sync
      } else {
      }
    } catch (e) {
      print("🚨 Error syncing usage time: $e");
    }
  }

  static Future<void> setUserStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
  }

  static Future<int?> getUserStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak');
  }

  static Future<void> setCurrentLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level);
  }

  static Future<String?> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('level');
  }

  static Future<void> setCompletedLessons(
    String level,
    List<String> lessons,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completed_$level', lessons);
  }

  static Future<List<String>> getCompletedLessons(String level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('completed_$level') ?? [];
  }

  static Future<void> addCompletedLesson(String level, String lessonKey) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> completed = prefs.getStringList('completed_$level') ?? [];

    if (!completed.contains(lessonKey)) {
      completed.add(lessonKey);
      await prefs.setStringList('completed_$level', completed);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
