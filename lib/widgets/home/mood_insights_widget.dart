import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heartlog/services/diary_storage_service.dart';
import 'package:heartlog/constants/index.dart';

class MoodInsightsWidget extends StatelessWidget {
  final DiaryStorageService diaryStorage;

  const MoodInsightsWidget({super.key, required this.diaryStorage});

  @override
  Widget build(BuildContext context) {
    // Menggunakan StreamBuilder untuk update data secara otomatis
    return StreamBuilder<List<dynamic>>(
      stream: diaryStorage.entriesStream,
      builder: (context, snapshot) {
        // Get fresh data from diary storage
        final String dominantEmotion = diaryStorage.getMostFrequentEmotion();
        final int streak = diaryStorage.getCurrentStreak();
        final double emotionalBalance = diaryStorage.getEmotionalBalance();
        final String moodSuggestion = diaryStorage.getMoodSuggestion();

        if (kDebugMode) {
          print('MoodInsights - EmotionalBalance: ${emotionalBalance * 100}%');
        }
        return Container(
          width: double.infinity, // Gunakan lebar penuh
          constraints: const BoxConstraints(
            maxWidth: 500,
          ), // Batasan lebar maksimum
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.5),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.cardBackground, AppColors.primaryLight],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Insights header
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Wawasan Suasana Hati",
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(Icons.insights, color: AppColors.primary, size: 24),
                  ],
                ),
              ),

              // Insights data section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInsightRow(
                      context,
                      "Emosi Dominan",
                      dominantEmotion.isEmpty ? "Belum Ada" : dominantEmotion,
                    ),
                    const SizedBox(height: 12),
                    _buildInsightRow(
                      context,
                      "Rentetan Catatan",
                      "$streak hari",
                    ),
                    const SizedBox(height: 12),
                    _buildInsightRow(
                      context,
                      "Keseimbangan Emosional",
                      "${(emotionalBalance * 100).round()}%",
                      showProgress: true,
                      progressValue: emotionalBalance,
                    ),
                  ],
                ),
              ),

              // Suggestion section
              if (moodSuggestion.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFFE05D2B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            moodSuggestion,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'NunitoSans',
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    String label,
    String value, {
    bool showProgress = false,
    double progressValue = 0.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'NunitoSans',
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE05D2B),
                fontFamily: 'NunitoSans',
              ),
            ),
          ],
        ),

        // Show progress bar if required
        if (showProgress) ...[
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Background bar
                  Container(
                    height: 8,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  // Progress indicator
                  Container(
                    height: 8,
                    width: constraints.maxWidth * progressValue.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            progressValue < 0.3
                                ? [Colors.red, Colors.orange]
                                : progressValue < 0.7
                                ? [Colors.orange, Colors.yellow]
                                : [Colors.green.shade300, Colors.green],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 4),

          // Progress level text
          Row(
            children: [
              const Spacer(),
              Text(
                _getBalanceText(progressValue),
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                  fontFamily: 'NunitoSans',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _getBalanceText(double value) {
    if (value < 0.3) return "Dominan Negatif";
    if (value < 0.4) return "Cenderung Negatif";
    if (value < 0.6) return "Seimbang";
    if (value < 0.8) return "Cenderung Positif";
    return "Dominan Positif";
  }
}
