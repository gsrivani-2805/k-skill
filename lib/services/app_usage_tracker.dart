import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageTracker with WidgetsBindingObserver {
  DateTime? _sessionStart;
  bool _isTracking = false;

  // Call this at app start (e.g., in main.dart)
  void startTracking() {
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _isTracking = true;
  }

  // Stop tracking (e.g., on logout or exit)
  Future<void> stopTracking() async {
    if (_isTracking && _sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      final prefs = await SharedPreferences.getInstance();
      double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;
      await prefs.setDouble('totalUsageSeconds', totalSeconds + duration.inSeconds);
    }
    WidgetsBinding.instance.removeObserver(this);
    _isTracking = false;
  }

  // This runs automatically when app is minimized or resumed
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferences.getInstance();
    double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;

    if (state == AppLifecycleState.paused) {
      // App moved to background → stop and store time
      if (_sessionStart != null) {
        final duration = DateTime.now().difference(_sessionStart!);
        await prefs.setDouble('totalUsageSeconds', totalSeconds + duration.inSeconds);
        _sessionStart = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      // App came back → start new session
      _sessionStart = DateTime.now();
    }
  }

  // reset manually if needed
  static Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalUsageSeconds', 0);
  }

  // Get total usage time in hours/minutes
  static Future<double> getTotalUsageHours() async {
    final prefs = await SharedPreferences.getInstance();
    double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;
    return totalSeconds / 3600; // convert to hours
  }
}
