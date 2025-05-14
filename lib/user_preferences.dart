import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferences {
  // Singleton pattern implementation
  static final UserPreferences _instance = UserPreferences._internal();

  factory UserPreferences() {
    return _instance;
  }

  UserPreferences._internal() {
    _loadUserName();
  }

  // Shared preferences key
  static const String _userNameKey = 'heartlog_user_name';

  // Default username
  String _userName = 'HeartLog User';

  // Stream controller for username changes
  final _userNameController = StreamController<String>.broadcast();

  // Stream that widgets can listen to for updates
  Stream<String> get userNameStream => _userNameController.stream;

  // Get current username
  String get userName => _userName;

  // Load username from shared preferences
  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_userNameKey);

      if (name != null && name.isNotEmpty) {
        _userName = name;
        _notifyListeners();
      }

      if (kDebugMode) {
        print('Loaded username: $_userName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading username: $e');
      }
    }
  }

  // Save username to shared preferences
  Future<void> setUserName(String newName) async {
    if (newName.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, newName);

      _userName = newName;
      _notifyListeners();

      if (kDebugMode) {
        print('Username changed to: $_userName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving username: $e');
      }
    }
  }

  // Notify listeners of changes
  void _notifyListeners() {
    _userNameController.add(_userName);
  }

  // Dispose the stream controller
  void dispose() {
    _userNameController.close();
  }
}
