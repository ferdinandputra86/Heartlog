import 'package:flutter/material.dart';
import 'package:heartlog/controllers/home/beranda_controller.dart';
import 'package:heartlog/services/diary_storage_service.dart';
import 'package:heartlog/widgets/home/mood_insights_widget.dart';
import 'package:heartlog/screens/write/write_screen.dart';
import 'package:heartlog/constants/index.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  late final BerandaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BerandaController();

    // Listen for username changes
    _controller.userNameStream.listen((userName) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 31, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 20),
                MoodInsightsWidget(diaryStorage: DiaryStorageService()),
                const SizedBox(height: 15),
                _buildEmotionPrompt(),
                const SizedBox(height: 20),
                _buildEmotionIcons(context),
                const SizedBox(height: 30),
                _buildWriteDiaryButton(context),
                const SizedBox(height: 20), // Padding di bawah untuk scroll
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    // Get greeting based on time of day
    String greeting = _controller.getTimeBasedGreeting();
    String displayName = _controller.getDisplayName();

    return Text(
      displayName.isEmpty
          ? "$greeting\nBagaimana harimu?"
          : "$greeting, $displayName\nBagaimana harimu?",
      style: AppTextStyles.headingLarge.copyWith(fontWeight: FontWeight.w400),
    );
  }

  Widget _buildEmotionPrompt() {
    return Text(
      "Bagaimana perasaanmu sekarang?",
      style: AppTextStyles.headingSmall,
    );
  }

  Widget _buildEmotionIcons(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung ukuran ikon berdasarkan lebar layar yang tersedia
        final double iconSize = constraints.maxWidth < 360 ? 60 : 72;
        final double spacing = constraints.maxWidth < 360 ? 4 : 8;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEmotionIcon(
              context,
              'assets/Emotion/senang.png',
              'Senang',
              iconSize,
            ),
            SizedBox(width: spacing),
            _buildEmotionIcon(
              context,
              'assets/Emotion/sedih.png',
              'Sedih',
              iconSize,
            ),
            SizedBox(width: spacing),
            _buildEmotionIcon(
              context,
              'assets/Emotion/takut.png',
              'Takut',
              iconSize,
            ),
            SizedBox(width: spacing),
            _buildEmotionIcon(
              context,
              'assets/Emotion/marah.png',
              'Marah',
              iconSize,
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmotionIcon(
    BuildContext context,
    String imagePath,
    String emotion, [
    double size = 72,
  ]) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteScreen(initialEmotion: emotion),
          ),
        );
        if (result == true) {
          _controller.loadLatestEntries();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error, size: size, color: Colors.red);
          },
        ),
      ),
    );
  }

  Widget _buildWriteDiaryButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WriteScreen()),
        );
        if (result == true) {
          _controller.loadLatestEntries();
        }
      },
      child: Container(
        width: double.infinity, // Gunakan lebar penuh
        constraints: const BoxConstraints(
          maxWidth: 500,
        ), // Batasan lebar maksimum
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.5),
          color: const Color(0xfffd745a),
        ),
        child: Center(
          child: Text(
            "Tulis Diarimu Hari Ini",
            style: TextStyle(
              fontSize:
                  MediaQuery.of(context).size.width < 360
                      ? 20
                      : 24, // Font yang responsif
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
