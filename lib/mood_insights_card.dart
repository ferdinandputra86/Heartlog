import 'package:flutter/material.dart';
import 'package:heartlog/diary_storage.dart';
import 'dart:math' as math;

class MoodInsightsCard extends StatelessWidget {
  final DiaryStorage diaryStorage;

  const MoodInsightsCard({Key? key, required this.diaryStorage})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get data from diary storage
    final String dominantEmotion = diaryStorage.getMostFrequentEmotion();
    final int streak = diaryStorage.getCurrentStreak();
    final double emotionalBalance = diaryStorage.getEmotionalBalance();
    final String moodSuggestion = diaryStorage.getMoodSuggestion();

    return Container(
      width: 328,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFFFEF8EF), const Color(0xFFFFE4D6)],
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
                const Text(
                  "Mood Insights",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE05D2B),
                  ),
                ),
                _buildMoodIcon(emotionalBalance),
              ],
            ),
          ),

          // Streak counter
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 8, right: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Color(0xFFE05D2B),
                  size: 20,
                ),
                const SizedBox(width: 5),
                Text(
                  "$streak day streak",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Dominant emotion
          if (dominantEmotion != "No entries yet" &&
              dominantEmotion != "No recent entries")
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 5, right: 20),
              child: Text(
                "Recent mood: $dominantEmotion",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Mood balance indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildMoodBalanceBar(emotionalBalance),
          ),

          // Mood suggestion
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 15),
            child: Text(
              moodSuggestion,
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodIcon(double emotionalBalance) {
    IconData iconData;
    Color iconColor;

    if (emotionalBalance > 0.7) {
      iconData = Icons.sentiment_very_satisfied;
      iconColor = Colors.green;
    } else if (emotionalBalance > 0.4) {
      iconData = Icons.sentiment_satisfied;
      iconColor = Colors.amber;
    } else {
      iconData = Icons.sentiment_dissatisfied;
      iconColor = Colors.redAccent;
    }

    return Icon(iconData, color: iconColor);
  }

  Widget _buildMoodBalanceBar(double emotionalBalance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Emotional Balance",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.amber, Colors.green],
            ),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.05, // Minimum size for marker
            child: Container(
              margin: EdgeInsets.only(
                left: math.max(0, emotionalBalance * 0.95 * 288 - 4),
              ), // Positioning the marker
              width: 8,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
