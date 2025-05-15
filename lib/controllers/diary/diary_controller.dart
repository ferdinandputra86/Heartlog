import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/services/diary_storage_service.dart';
import 'dart:async';

class DiaryController {
  final DiaryStorageService _diaryStorage = DiaryStorageService();

  // Stream controller for diary entries
  final _entriesStreamController =
      StreamController<List<DiaryEntry>>.broadcast();

  // Stream for UI to listen to
  Stream<List<DiaryEntry>> get entriesStream => _entriesStreamController.stream;

  DiaryController() {
    // Initialize by loading entries and listening for changes
    _loadEntries();
    _diaryStorage.entriesStream.listen((entries) {
      _entriesStreamController.add(entries);
    });
  }

  void _loadEntries() {
    final entries = _diaryStorage.getEntries();
    _entriesStreamController.add(entries);
  }

  List<DiaryEntry> getAllEntries() {
    return _diaryStorage.getEntries();
  }

  // Returns entries sorted by date (newest first)
  List<DiaryEntry> getEntriesByDate() {
    return _diaryStorage.getEntriesByDate();
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    await _diaryStorage.deleteEntry(entry);
  }

  Future<void> deleteAllEntries() async {
    await _diaryStorage.deleteAllEntries();
  }

  void dispose() {
    _entriesStreamController.close();
  }
}
