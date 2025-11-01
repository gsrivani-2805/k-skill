import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  // 🔹 User ID
  static Future<void> setUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // 🔹 User Name
  static Future<void> setUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  // 🔹 JWT Token + Login Time
  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    // Also store login time when token is set
    await prefs.setString('loginTime', DateTime.now().toIso8601String());
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🔹 Check if token is expired (24 hours)
  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimeStr = prefs.getString('loginTime');

    if (loginTimeStr == null) return false;

    final loginTime = DateTime.parse(loginTimeStr);
    final now = DateTime.now();

    // Expire after 24 hours
    if (now.difference(loginTime).inHours >= 24) {
      await logout();
      return false;
    }
    return true;
  }

  // 🔹 User Streak
  static Future<void> setUserStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
  }

  static Future<int?> getUserStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak');
  }

  // 🔹 Current Level
  static Future<void> setCurrentLevel(String level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level);
  }

  static Future<String?> getCurrentLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('level');
  }

  // 🔹 Completed Lessons
  static Future<void> setCompletedLessons(String level, List<String> lessons) async {
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

  // 🔹 Clear All or Logout
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
