import 'package:flutter/material.dart';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/services/diary_storage_service.dart';

class StatisticController {
  final DiaryStorageService _diaryStorage = DiaryStorageService();

  List<DiaryEntry> _entries = [];
  Map<String, int> _emotionCounts = {};
  Map<int, double> _dailyMoodScores = {};
  Map<int, double> _monthlyMoodScores = {};

  // Getters for the data
  List<DiaryEntry> get entries => _entries;
  Map<String, int> get emotionCounts => _emotionCounts;
  Map<int, double> get dailyMoodScores => _dailyMoodScores;
  Map<int, double> get monthlyMoodScores => _monthlyMoodScores;

  // Stream for UI to listen to
  Stream<List<DiaryEntry>> get entriesStream => _diaryStorage.entriesStream;

  void loadEntries() {
    _entries = _diaryStorage.getEntriesByDate();
    _processEntries(_entries);
  }

  void _processEntries(List<DiaryEntry> entries) {
    _entries = entries;
    // Count emotions
    _emotionCounts = {};
    for (var entry in entries) {
      // Use a fallback value if emotion is empty or null
      String emotion =
          entry.emotion.trim().isNotEmpty ? entry.emotion : "Unknown";
      _emotionCounts[emotion] = (_emotionCounts[emotion] ?? 0) + 1;
    }

    // Calculate daily mood scores for the past week
    _dailyMoodScores = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayEntries =
          entries
              .where(
                (entry) =>
                    entry.date.year == day.year &&
                    entry.date.month == day.month &&
                    entry.date.day == day.day,
              )
              .toList();

      if (dayEntries.isNotEmpty) {
        // Simple scoring: Senang=5, default=3
        double dayScore = 0;
        for (var entry in dayEntries) {
          switch (entry.emotion) {
            case 'Senang':
              dayScore += 5;
              break;
            case 'Marah':
              dayScore += 2;
              break;
            case 'Sedih':
              dayScore += 1;
              break;
            case 'Takut':
              dayScore += 1;
              break;
            default:
              dayScore += 3;
          }
        }
        _dailyMoodScores[i] = dayScore / dayEntries.length;
      } else {
        _dailyMoodScores[i] = 0; // No entries for this day
      }
    }

    // Calculate monthly mood scores for the past 4 months
    _monthlyMoodScores = {};
    for (int i = 3; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEntries =
          entries
              .where(
                (entry) =>
                    entry.date.year == month.year &&
                    entry.date.month == month.month,
              )
              .toList();

      if (monthEntries.isNotEmpty) {
        // Simple scoring: Senang=80, default=50
        double monthScore = 0;
        for (var entry in monthEntries) {
          switch (entry.emotion) {
            case 'Senang':
              monthScore += 80;
              break;
            case 'Marah':
              monthScore += 30;
              break;
            case 'Sedih':
              monthScore += 20;
              break;
            case 'Takut':
              monthScore += 40;
              break;
            default:
              monthScore += 50;
          }
        }
        _monthlyMoodScores[i] = monthScore / monthEntries.length;
      } else {
        _monthlyMoodScores[i] = 0; // No entries for this month
      }
    }
  }
}
