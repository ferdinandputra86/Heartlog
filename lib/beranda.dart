import 'package:flutter/material.dart';
import 'package:heartlog/notes.dart';
import 'package:heartlog/diary_storage.dart';
import 'package:heartlog/write.dart';
import 'package:heartlog/user_preferences.dart';

class Beranda extends StatefulWidget {
  const Beranda({super.key});

  @override
  State<Beranda> createState() => _BerandaState();
}

class _BerandaState extends State<Beranda> {
  final DiaryStorage _diaryStorage = DiaryStorage();
  final UserPreferences _userPreferences = UserPreferences();
  List<DiaryEntry> _latestEntries = [];
  late String _userName;

  @override
  void initState() {
    super.initState();
    _loadLatestEntries();
    _userName = _userPreferences.userName;

    // Listen for changes in diary entries
    _diaryStorage.entriesStream.listen((entries) {
      if (mounted) {
        setState(() {
          _latestEntries = _getLatestEntries(entries);
        });
      }
    });

    // Listen for username changes
    _userPreferences.userNameStream.listen((newName) {
      if (mounted) {
        setState(() {
          _userName = newName;
        });
      }
    });
  }

  void _loadLatestEntries() {
    _latestEntries = _getLatestEntries(_diaryStorage.getEntries());
  }

  List<DiaryEntry> _getLatestEntries(List<DiaryEntry> allEntries) {
    // Sort entries by date (newest first) and take only the 3 most recent
    final sortedEntries = List<DiaryEntry>.from(allEntries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sortedEntries.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildWeatherCard(),
              const SizedBox(height: 15),
              _buildEmotionPrompt(),
              const SizedBox(height: 20),
              _buildEmotionIcons(),
              const SizedBox(height: 30),
              _buildWriteDiaryButton(context),
              const SizedBox(height: 30),
              _buildDiaryListHeader(),
              _buildDiaryList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    // Extract the first name if there are multiple words
    String displayName = _userName.split(' ').first;
    
    // If the name is "HeartLog User", just display "Hai"
    if (_userName == "HeartLog User") {
      displayName = "";
    }
    
    return Text(
      displayName.isEmpty 
          ? "Hai\nGimana harimu?"
          : "Hai, $displayName\nGimana harimu?",
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: 328,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.5),
        color: const Color(0xfffef8ef),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset('assets/cuaca.png', width: 56, height: 56),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Berawan, 28 C",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 5),
              Text(
                "Kediri",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionPrompt() {
    return const Text(
      "Bagaimana Perasaanmu sekarang?",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildEmotionIcons() {
    return Row(
      children: [
        _buildEmotionIcon('assets/Emotion/senang.png'),
        const SizedBox(width: 16),
        _buildEmotionIcon('assets/Emotion/sedih.png'),
        const SizedBox(width: 16),
        _buildEmotionIcon('assets/Emotion/takut.png'),
        const SizedBox(width: 16),
        _buildEmotionIcon('assets/Emotion/marah.png'),
      ],
    );
  }

  Widget _buildEmotionIcon(String imagePath) {
    return Image.asset(
      imagePath,
      width: 72,
      height: 72,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, size: 72, color: Colors.red);
      },
    );
  }

  Widget _buildWriteDiaryButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Write()),
        );
        if (result == true) {
          setState(() {
            // Refresh UI when returning from Write screen
            // Reload the latest entries
            _loadLatestEntries();
          });
        }
      },
      child: Container(
        width: 328,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.5),
          color: const Color(0xfffd745a),
        ),
        child: const Center(
          child: Text(
            "Tulis Dairymu Hari Ini",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryListHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12.0),
      child: Text(
        "Recent Entries",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xfffd745a),
        ),
      ),
    );
  }

  Widget _buildDiaryList() {
    if (_latestEntries.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'No diary entries yet. Click the button to create one!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF666666), fontSize: 16),
          ),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.only(
            bottom: 80,
          ), // Add padding for bottom navigation bar
          physics: const BouncingScrollPhysics(),
          itemCount: _latestEntries.length,
          itemBuilder: (context, index) {
            final entry = _latestEntries[index];
            return Notes(
              emotion: entry.emotion,
              keywords: "", // DiaryEntry doesn't have keywords field
              suggestion: entry.suggestion,
              imagePath: entry.imagePath,
              text: entry.text,
            );
          },
        ),
      );
    }
  }
}
