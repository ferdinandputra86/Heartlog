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
}
