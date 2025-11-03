import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:K_Skill/services/shared_prefs.dart';

/// Tracks total app usage time (in seconds) and syncs it with backend.
class AppUsageTracker with WidgetsBindingObserver {
  DateTime? _sessionStart;
  bool _isTracking = false;

  /// Start tracking when app launches (call this in `main()` or after login)
  void startTracking() {
    if (_isTracking) return;
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
    _isTracking = true;
  }

  /// Stop tracking manually (e.g., on logout or app exit)
  Future<void> stopTracking() async {
    if (_isTracking && _sessionStart != null) {
      final duration = DateTime.now().difference(_sessionStart!);
      final prefs = await SharedPreferences.getInstance();

      // Read previous total seconds
      double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;
      final updated = totalSeconds + duration.inSeconds;

      // Store updated total usage time locally
      await prefs.setDouble('totalUsageSeconds', updated);

      // Add this session time to backend sync buffer
      await SharedPrefsService.addActiveTime(duration.inSeconds);
    }

    WidgetsBinding.instance.removeObserver(this);
    _isTracking = false;
    _sessionStart = null;
  }

  /// React to app lifecycle changes (background/resume)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    final prefs = await SharedPreferences.getInstance();
    double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;

    switch (state) {
      case AppLifecycleState.paused:
        // App going to background → save partial session
        if (_sessionStart != null) {
          final duration = DateTime.now().difference(_sessionStart!);
          final updated = totalSeconds + duration.inSeconds;
          await prefs.setDouble('totalUsageSeconds', updated);
          await SharedPrefsService.addActiveTime(duration.inSeconds);
          _sessionStart = null; // Reset for next session
        }
        break;

      case AppLifecycleState.resumed:
        // App reopened → start new session
        _sessionStart = DateTime.now();
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        // Edge case: ensure unsaved time is flushed
        if (_sessionStart != null) {
          final duration = DateTime.now().difference(_sessionStart!);
          final updated = totalSeconds + duration.inSeconds;
          await prefs.setDouble('totalUsageSeconds', updated);
          await SharedPrefsService.addActiveTime(duration.inSeconds);
          _sessionStart = null;
        }
        break;

      default:
        break;
    }
  }

  /// Reset all usage data manually
  static Future<void> resetUsage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalUsageSeconds', 0);
    await SharedPrefsService.resetActiveTime();
  }

  /// Retrieve total usage time in hours
  static Future<double> getTotalUsageHours() async {
    final prefs = await SharedPreferences.getInstance();
    double totalSeconds = prefs.getDouble('totalUsageSeconds') ?? 0;
    return totalSeconds / 3600;
  }

  /// Sync accumulated usage time with backend (called on logout)
  static Future<void> syncUsageToServer() async {
    await SharedPrefsService.syncActiveTimeWithServer();
  }
}
