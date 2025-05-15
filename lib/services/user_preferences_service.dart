import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class UserPreferencesService {
  static final UserPreferencesService _instance =
      UserPreferencesService._internal();

  factory UserPreferencesService() {
    return _instance;
  }

  UserPreferencesService._internal() {
    _loadPreferences();
  }

  // Keys
  static const String _userNameKey = 'user_name';
  static const String _defaultUserName = 'HeartLog User';

  // Properties
  String _userName = _defaultUserName;
  String get userName => _userName;

  // Stream controller
  final _userNameController = StreamController<String>.broadcast();
  Stream<String> get userNameStream => _userNameController.stream;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString(_userNameKey) ?? _defaultUserName;
      _userNameController.add(_userName);

      if (kDebugMode) {
        print('Loaded user preferences: userName=$_userName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading preferences: $e');
      }
      // Set to defaults in case of error
      _userName = _defaultUserName;
      _userNameController.add(_userName);
    }
  }

  Future<void> setUserName(String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userNameKey, newName);
      _userName = newName;
      _userNameController.add(_userName);

      if (kDebugMode) {
        print('User name updated to: $newName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user name: $e');
      }
      rethrow;
    }
  }

  Future<void> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _userName = _defaultUserName;
      _userNameController.add(_userName);

      if (kDebugMode) {
        print('Reset user preferences to defaults');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting preferences: $e');
      }
      rethrow;
    }
  }

  void dispose() {
    _userNameController.close();
  }
}
