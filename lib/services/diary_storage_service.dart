import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:heartlog/models/diary_entry.dart';

class DiaryStorageService {
  static final DiaryStorageService _instance = DiaryStorageService._internal();

  // Factory constructor to return the same instance
  factory DiaryStorageService() {
    return _instance;
  }

  // Private constructor
  DiaryStorageService._internal() {
    _loadEntries();
  }

  final String _storageKey = 'diary_entries';
  List<DiaryEntry> _entries = [];

  // Stream controller to notify listeners when entries change
  final _entriesStreamController =
      StreamController<List<DiaryEntry>>.broadcast();

  // Expose a stream for listeners
  Stream<List<DiaryEntry>> get entriesStream => _entriesStreamController.stream;

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = prefs.getStringList(_storageKey) ?? [];

      _entries =
          entriesJson
              .map((entryStr) => DiaryEntry.fromJson(jsonDecode(entryStr)))
              .toList();

      _entriesStreamController.add(_entries);

      if (kDebugMode) {
        print('Loaded ${_entries.length} diary entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading diary entries: $e');
      }
      // In case of error, initialize with empty list
      _entries = [];
      _entriesStreamController.add(_entries);
    }
  }

  Future<void> saveEntry(DiaryEntry entry) async {
    try {
      _entries.add(entry);
      await _saveEntries();
      _entriesStreamController.add(_entries);

      if (kDebugMode) {
        print('Added new diary entry: ${entry.emotion}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving entry: $e');
      }
      rethrow; // Re-throw to let UI handle error
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entriesJson = _entries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_storageKey, entriesJson);

      if (kDebugMode) {
        print('Saved ${_entries.length} diary entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving entries: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    try {
      _entries.removeWhere(
        (e) =>
            e.date.isAtSameMomentAs(entry.date) &&
            e.emotion == entry.emotion &&
            e.text == entry.text,
      );

      await _saveEntries();
      _entriesStreamController.add(_entries);

      if (kDebugMode) {
        print('Deleted diary entry');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting entry: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteAllEntries() async {
    try {
      _entries.clear();
      await _saveEntries();
      _entriesStreamController.add(_entries);

      if (kDebugMode) {
        print('Deleted all diary entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all entries: $e');
      }
      rethrow;
    }
  }

  List<DiaryEntry> getEntries() {
    return List<DiaryEntry>.from(_entries);
  }

  // Returns entries sorted by date (newest first)
  List<DiaryEntry> getEntriesByDate() {
    final sortedEntries = List<DiaryEntry>.from(_entries);
    sortedEntries.sort((a, b) => b.date.compareTo(a.date));
    return sortedEntries;
  }

  void dispose() {
    _entriesStreamController.close();
  }

  // Fungsi untuk mood insights widget
  String getMostFrequentEmotion() {
    if (_entries.isEmpty) return "Belum ada";

    final Map<String, int> emotionCount = {};
    for (var entry in _entries) {
      emotionCount[entry.emotion] = (emotionCount[entry.emotion] ?? 0) + 1;
    }

    String mostFrequent = "Belum ada";
    int maxCount = 0;
    emotionCount.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        mostFrequent = emotion;
      }
    });

    return mostFrequent;
  }

  int getCurrentStreak() {
    if (_entries.isEmpty) return 0;

    // Sort entries by date (newest first)
    final sortedEntries = List.from(_entries)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 1;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if the latest entry is from today
    final latestEntry = sortedEntries.first;
    final latestDate = DateTime(
      latestEntry.date.year,
      latestEntry.date.month,
      latestEntry.date.day,
    );

    if (latestDate.isAtSameMomentAs(todayDate)) {
      // Latest entry is today, count streak backwards
      DateTime previousDate = todayDate.subtract(const Duration(days: 1));

      for (int i = 1; i < sortedEntries.length; i++) {
        final entryDate = DateTime(
          sortedEntries[i].date.year,
          sortedEntries[i].date.month,
          sortedEntries[i].date.day,
        );

        if (entryDate.isAtSameMomentAs(previousDate)) {
          streak++;
          previousDate = previousDate.subtract(const Duration(days: 1));
        } else if (entryDate.isBefore(previousDate)) {
          // Skip ahead to the date of this entry
          previousDate = entryDate.subtract(const Duration(days: 1));
        } else {
          // Streak broken
          break;
        }
      }
    } else {
      // Latest entry is not today, streak is 0
      streak = 0;
    }

    return streak;
  }

  double getEmotionalBalance() {
    if (_entries.isEmpty) return 0.5; // Neutral if no entries

    double positiveCount = 0;
    double negativeCount = 0;
    double neutralCount = 0;

    // Only consider entries from the last 30 days for more relevant insights
    final DateTime thirtyDaysAgo = DateTime.now().subtract(
      const Duration(days: 30),
    );
    final recentEntries =
        _entries.where((entry) => entry.date.isAfter(thirtyDaysAgo)).toList();

    if (recentEntries.isEmpty) return 0.5; // Neutral if no recent entries

    // Assign weights to emotions
    for (var entry in recentEntries) {
      final String emotion = entry.emotion.toLowerCase();
      if (emotion == "senang") {
        positiveCount += 1.0;
      } else if (emotion == "sedih") {
        negativeCount += 0.8;
      } else if (emotion == "marah") {
        negativeCount += 1.0;
      } else if (emotion == "takut") {
        negativeCount += 0.7;
      } else {
        neutralCount += 0.5;
      }
    }

    final total = positiveCount + negativeCount + neutralCount;
    if (total == 0) return 0.5;

    // Calculate balance as ratio of positive emotions to total
    double balance = positiveCount / total;

    // Ensure balance is between 0 and 1
    balance = balance.clamp(0.0, 1.0);

    if (kDebugMode) {
      print('Emotional Balance: $balance (${balance * 100}%)');
      print(
        'Positive: $positiveCount, Negative: $negativeCount, Neutral: $neutralCount, Total: $total',
      );
    }

    return balance;
  }

  String getMoodSuggestion() {
    if (_entries.isEmpty) {
      return "Selamat datang! Mulailah menulis jurnal harian untuk melihat wawasan tentang emosi Anda.";
    }

    final balance = getEmotionalBalance();
    final dominantEmotion = getMostFrequentEmotion();
    final streak = getCurrentStreak();

    // More varied suggestions based on emotional balance percentage
    if (balance < 0.2) {
      return "Akhir-akhir ini Anda sering merasa $dominantEmotion. Cobalah melakukan aktivitas yang menyenangkan seperti jalan-jalan, menonton film favorit, atau berbicara dengan teman dekat.";
    } else if (balance < 0.4) {
      return "Anda cenderung lebih sering merasa $dominantEmotion. Mungkin sekarang adalah waktu yang tepat untuk melakukan beberapa perawatan diri dan refleksi. Cobalah bermeditasi selama 5-10 menit setiap hari.";
    } else if (balance < 0.6) {
      if (streak > 3) {
        return "Keseimbangan emosi Anda stabil dan Anda telah menulis jurnal selama $streak hari berturut-turut. Konsistensi Anda menakjubkan! Teruslah mencatat perasaan Anda.";
      } else {
        return "Keseimbangan emosi Anda cukup stabil. Tetaplah menulis jurnal secara teratur untuk memahami pola emosi Anda dengan lebih baik.";
      }
    } else if (balance < 0.8) {
      return "Anda lebih sering merasa positif! Bagikan energi positif Anda dengan orang lain dan jangan lupa mencatat hal-hal yang membuat Anda bahagia untuk refleksi di masa mendatang.";
    } else {
      return "Luar biasa! Keseimbangan emosi Anda sangat positif. Jaga kebiasaan baik ini ya, dan coba identifikasi faktor-faktor yang berkontribusi pada kebahagiaan Anda.";
    }
  }
}
