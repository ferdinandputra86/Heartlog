import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/controllers/diary/diary_controller.dart';
import 'package:heartlog/widgets/diary/diary_note.dart';
import 'package:heartlog/constants/index.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  // List to hold diary entries
  List<DiaryEntry> entries = [];
  // DiaryController instance
  final DiaryController _diaryController = DiaryController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    // Initial load of entries
    _loadEntries();

    // Listen to entry changes using the stream
    _diaryController.entriesStream.listen((updatedEntries) {
      if (mounted) {
        setState(() {
          entries = updatedEntries;
        });
      }
    });
  }

  // Refresh entries from DiaryController
  void _loadEntries() {
    entries = _diaryController.getEntriesByDate();
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan entri terbaru selalu ada di atas dengan melakukan sort ulang
    final sortedEntries = List<DiaryEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Diari Saya',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            fontSize: MediaQuery.of(context).size.width < 360 ? 18 : 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SafeArea(
        child:
            sortedEntries.isEmpty
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Belum ada catatan diari. Tulis catatan pertamamu!',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView.builder(
                        itemCount: sortedEntries.length,
                        itemBuilder: (context, index) {
                          final entry = sortedEntries[index];
                          return DiaryNote(
                            emotion: entry.emotion,
                            keywords: "", // You may want to add keywords to DiaryEntry
                            suggestion: entry.suggestion,
                            imagePath: entry.imagePath,
                            text: entry.text,
                            date: entry.date,
                          );
                        },
                      );
                    },
                  ),
                ),
      ),
    );
  }
}
