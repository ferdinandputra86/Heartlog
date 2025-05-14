import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';

class DiaryEntry {
  final String text;
  final DateTime date;
  final String emotion;
  final String suggestion;
  final String imagePath;

  DiaryEntry({
    required this.text,
    required this.date,
    required this.emotion,
    required this.suggestion,
    required this.imagePath,
  });

  // For debugging purposes
  @override
  String toString() {
    return 'DiaryEntry(date: $date, emotion: $emotion, text: ${text.substring(0, text.length > 30 ? 30 : text.length)}...)';
  }

  // Convert DiaryEntry to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'date': date.toIso8601String(),
      'emotion': emotion,
      'suggestion': suggestion,
      'imagePath': imagePath,
    };
  }

  // Create DiaryEntry from JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      text: json['text'] as String,
      date: DateTime.parse(json['date'] as String),
      emotion: json['emotion'] as String,
      suggestion: json['suggestion'] as String,
      imagePath: json['imagePath'] as String,
    );
  }
}

class DiaryStorage {
  // Singleton pattern implementation
  static final DiaryStorage _instance = DiaryStorage._internal();

  factory DiaryStorage() {
    return _instance;
  }

  // In-memory storage
  final List<DiaryEntry> _entries = [];

  // Stream controller untuk notifikasi perubahan data
  final _entriesStreamController =
      StreamController<List<DiaryEntry>>.broadcast();

  // Stream yang bisa didengarkan oleh widget untuk mendapatkan update
  Stream<List<DiaryEntry>> get entriesStream => _entriesStreamController.stream;
  // SharedPreferences key
  static const String _storageKey = 'heartlog_diary_entries';

  // Initialize and load data from SharedPreferences
  DiaryStorage._internal() {
    _loadEntries();
  }
  // Load entries from SharedPreferences
  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_storageKey);

      if (entriesJson != null && entriesJson.isNotEmpty) {
        _entries.clear();
        for (var json in entriesJson) {
          try {
            final Map<String, dynamic> entryMap = jsonDecode(json);
            _entries.add(DiaryEntry.fromJson(entryMap));
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing entry: $e');
            }
          }
        }

        // Notifikasi ke stream untuk update UI
        _notifyListeners();

        if (kDebugMode) {
          print('Loaded ${_entries.length} entries from storage');
        }
      } else {
        // Initialize with empty entries when storage is empty
        _entries.clear();

        // No need to save empty entries
        // _saveEntries();
        if (kDebugMode) {
          print('Storage was empty, initialized with empty entries list');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading entries from storage: $e');
      }
    }
  }

  // Save entries to SharedPreferences
  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson =
          _entries.map((entry) => jsonEncode(entry.toJson())).toList();

      // Print the first entry JSON for debugging
      if (kDebugMode && entriesJson.isNotEmpty) {
        print('First entry JSON: ${entriesJson[0]}');
      }

      await prefs.setStringList(_storageKey, entriesJson);
      if (kDebugMode) {
        print(
          'Saved ${_entries.length} entries to storage with key $_storageKey',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving entries to storage: $e');
      }
    }
  } // Add a new diary entry

  void addEntry(DiaryEntry entry) {
    _entries.add(entry);
    _saveEntries(); // Save to persistent storage

    // Notifikasi ke stream untuk update UI
    _notifyListeners();

    if (kDebugMode) {
      print('Added new diary entry: ${entry.toString()}');
      print('Total entries: ${_entries.length}');
    }
  }

  // Get all entries
  List<DiaryEntry> getEntries() {
    // Return a copy to prevent direct modification
    return List.from(_entries);
  }

  // Get entries sorted by date (newest first)
  List<DiaryEntry> getEntriesByDate() {
    final sortedEntries = List<DiaryEntry>.from(_entries);
    sortedEntries.sort((a, b) => b.date.compareTo(a.date));
    return sortedEntries;
  }

  // Remove an entry
  void removeEntry(DiaryEntry entry) {
    _entries.remove(entry);
    _saveEntries(); // Save to persistent storage

    // Notifikasi ke stream untuk update UI
    _notifyListeners();

    if (kDebugMode) {
      print('Removed diary entry: ${entry.toString()}');
      print('Remaining entries: ${_entries.length}');
    }
  }

  // Notifikasi perubahan data ke listeners
  void _notifyListeners() {
    final sortedEntries = getEntriesByDate();
    _entriesStreamController.add(sortedEntries);
  }

  // Explicitly reload entries from storage
  Future<void> reloadEntries() async {
    await _loadEntries();
  }

  // Dispose stream controller when not needed
  void dispose() {
    _entriesStreamController.close();
  }

  // Get suggestion based on emotion
  static String getSuggestionForEmotion(String emotion) {
    switch (emotion) {
      case 'Senang':
        return 'Bagikan kebahagiaanmu dengan orang lain.';
      case 'Sedih':
        return 'Dengarkan musik atau hubungi teman untuk ngobrol.';
      case 'Marah':
        return 'Coba tarik napas dalam-dalam dan tenangkan diri.';
      case 'Takut':
        return 'Bicarakan kekhawatiranmu dengan seseorang yang kamu percaya.';
      default:
        return 'Refleksi dan catat perasaanmu setiap hari untuk memahami diri lebih baik.';
    }
  }

  // Get image path based on emotion
  static String getImagePathForEmotion(String emotion) {
    switch (emotion) {
      case 'Senang':
        return 'assets/Emotion/senang.png';
      case 'Sedih':
        return 'assets/Emotion/sedih.png';
      case 'Marah':
        return 'assets/Emotion/marah.png';
      case 'Takut':
        return 'assets/Emotion/takut.png';
      default:
        return 'assets/Emotion/senang.png';
    }
  }

  // Debug function to print all entries
  void debugPrintAllEntries() {
    if (kDebugMode) {
      print("======= All DiaryStorage Entries =======");
      print("Total entries: ${_entries.length}");
      for (var i = 0; i < _entries.length; i++) {
        final entry = _entries[i];
        print(
          "[$i] ${entry.date} - ${entry.emotion}: ${entry.text.substring(0, entry.text.length > 30 ? 30 : entry.text.length)}...",
        );
      }
      print("======================================");
    }
  }

  // Delete all diary entries
  Future<void> deleteAllEntries() async {
    _entries.clear();
    await _saveEntries(); // Save empty list to persistent storage

    // Notify listeners about the change
    _notifyListeners();

    if (kDebugMode) {
      print('All diary entries have been deleted');
    }
  }

  // Get most frequent emotion in the last week
  String getMostFrequentEmotion() {
    if (_entries.isEmpty) {
      return "No entries yet";
    }

    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    // Filter entries from the last week
    final recentEntries =
        _entries.where((entry) => entry.date.isAfter(lastWeek)).toList();

    if (recentEntries.isEmpty) {
      return "No recent entries";
    }

    // Count emotions
    final Map<String, int> emotionCount = {};
    for (var entry in recentEntries) {
      emotionCount[entry.emotion] = (emotionCount[entry.emotion] ?? 0) + 1;
    }

    // Find the most frequent emotion
    String mostFrequent = recentEntries.first.emotion;
    int highestCount = 0;

    emotionCount.forEach((emotion, count) {
      if (count > highestCount) {
        mostFrequent = emotion;
        highestCount = count;
      }
    });

    return mostFrequent;
  }

  // Get streak (consecutive days with entries)
  int getCurrentStreak() {
    if (_entries.isEmpty) {
      return 0;
    }

    // Sort entries by date (newest first)
    final sortedEntries = List<DiaryEntry>.from(_entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Get today's date without time component
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    // Get the date of the most recent entry
    final latestEntryDate = DateTime(
      sortedEntries.first.date.year,
      sortedEntries.first.date.month,
      sortedEntries.first.date.day,
    );

    // If the most recent entry is not from today or yesterday, streak is 0
    if (today.difference(latestEntryDate).inDays > 1) {
      return 0;
    }
    // Count streak
    int streak = 1; // Start with 1 for the most recent day

    // Create a map to track which dates have entries (to handle multiple entries per day)
    final Map<String, bool> datesWithEntries = {};
    for (var entry in sortedEntries) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      datesWithEntries[entryDate.toString()] = true;
    }

    // Check consecutive days
    for (int i = 1; ; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final checkDateStr = checkDate.toString().split(' ')[0];

      if (datesWithEntries.containsKey(checkDateStr)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  // Get emotional balance (ratio of positive to negative emotions)
  double getEmotionalBalance() {
    if (_entries.isEmpty) {
      return 0.5; // Neutral if no entries
    }

    int positive = 0;
    int negative = 0;

    for (var entry in _entries) {
      // Classify emotions as positive or negative
      // You can customize this based on your emotion categories
      if (entry.emotion.toLowerCase().contains('senang') ||
          entry.emotion.toLowerCase() == 'happy') {
        positive++;
      } else if (entry.emotion.toLowerCase().contains('sedih') ||
          entry.emotion.toLowerCase() == 'sad' ||
          entry.emotion.toLowerCase().contains('marah') ||
          entry.emotion.toLowerCase() == 'angry' ||
          entry.emotion.toLowerCase().contains('takut') ||
          entry.emotion.toLowerCase() == 'fear') {
        negative++;
      }
    }

    final total = positive + negative;
    if (total == 0) return 0.5;

    return positive / total; // Value between 0.0 and 1.0
  }

  // Get mood improvement suggestions based on emotional state
  String getMoodSuggestion() {
    if (_entries.isEmpty) {
      return "Start writing about your day to get personalized suggestions";
    }

    final emotionalBalance = getEmotionalBalance();

    if (emotionalBalance >= 0.7) {
      return "Your mood is great! Keep up the positive mindset";
    } else if (emotionalBalance >= 0.4) {
      return "Try reflecting on what made you happy recently";
    } else {
      return "Consider taking some time for self-care today";
    }
  }
}
