import 'dart:async';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/services/diary_storage_service.dart';
import 'package:heartlog/services/user_preferences_service.dart';

class BerandaController {
  final DiaryStorageService _diaryStorage = DiaryStorageService();
  final UserPreferencesService _userPreferences = UserPreferencesService();
  List<DiaryEntry> latestEntries = [];
  String userName = "";

  // Stream controllers for UI updates
  final StreamController<List<DiaryEntry>> _entriesController =
      StreamController<List<DiaryEntry>>.broadcast();
  final StreamController<String> _userNameController =
      StreamController<String>.broadcast();

  // Streams that UI can listen to
  Stream<List<DiaryEntry>> get entriesStream => _entriesController.stream;
  Stream<String> get userNameStream => _userNameController.stream;

  BerandaController() {
    _initialize();
  }

  void _initialize() async {
    // Load data
    loadLatestEntries();
    userName = _userPreferences.userName;
    _userNameController.add(userName);

    // Listen for changes
    _diaryStorage.entriesStream.listen((entries) {
      latestEntries = _getLatestEntries(entries);
      _entriesController.add(latestEntries);
    });

    _userPreferences.userNameStream.listen((newName) {
      userName = newName;
      _userNameController.add(userName);
    });
  }

  void loadLatestEntries() {
    latestEntries = _getLatestEntries(_diaryStorage.getEntries());
    _entriesController.add(latestEntries);
  }

  List<DiaryEntry> _getLatestEntries(List<DiaryEntry> allEntries) {
    final sortedEntries = List<DiaryEntry>.from(allEntries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedEntries.take(3).toList();
  }

  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) {
      return "Pagi";
    } else if (hour < 15) {
      return "Siang";
    } else if (hour < 19) {
      return "Sore";
    } else {
      return "Malam";
    }
  }

  String getDisplayName() {
    String displayName = userName.split(' ').first;
    if (userName == "HeartLog User") {
      return "";
    }
    return displayName;
  }

  void dispose() {
    _entriesController.close();
    _userNameController.close();
  }
}
