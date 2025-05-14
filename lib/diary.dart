import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:heartlog/notes.dart';
import 'package:heartlog/diary_storage.dart'; // Import DiaryStorage

class Diary extends StatefulWidget {
  const Diary({super.key});

  @override
  State<Diary> createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
  // List to hold diary entries
  late List<DiaryEntry> entries;
  // DiaryStorage instance
  final DiaryStorage _diaryStorage = DiaryStorage();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    // Initial load of entries
    _loadEntries();

    // Listen to entry changes using the stream
    _diaryStorage.entriesStream.listen((updatedEntries) {
      if (mounted) {
        setState(() {
          entries = updatedEntries;
        });
      }
    });
  }

  // Refresh entries from DiaryStorage
  void _loadEntries() {
    entries = _diaryStorage.getEntriesByDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Diary Entries'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body:
          entries.isEmpty
              ? const Center(
                child: Text(
                  'No diary entries yet. Write your first entry!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Notes(
                      emotion: entry.emotion,
                      keywords:
                          "", // You may want to add keywords to DiaryEntry
                      suggestion: entry.suggestion,
                      imagePath: entry.imagePath,
                      text: entry.text,
                      date: entry.date, // Pass the date to the Notes widget
                    );
                  },
                ),
              ),
    );
  }
}
