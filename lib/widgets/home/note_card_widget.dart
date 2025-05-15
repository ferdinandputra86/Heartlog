import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCardWidget extends StatelessWidget {
  final String emotion;
  final String keywords;
  final String suggestion;
  final String imagePath;
  final String? text;
  final DateTime? date;

  const NoteCardWidget({
    super.key,
    required this.emotion,
    required this.keywords,
    required this.suggestion,
    required this.imagePath,
    this.text,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // First row with emotion and date display
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getEmotionColor(emotion),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          emotion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Format and display the date
                      if (date != null)
                        Text(
                          DateFormat('dd/MM/yyyy, HH:mm').format(date!),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'NunitoSans',
                          ),
                        ),
                    ],
                  ),
                ),
                // Emotion icon
                Image.asset(
                  imagePath,
                  width: 30,
                  height: 30,
                  errorBuilder: (ctx, error, stackTrace) {
                    return const Icon(
                      Icons.mood,
                      size: 30,
                      color: Colors.amber,
                    );
                  },
                ),
              ],
            ),

            // Display the note content
            if (text != null && text!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                text!,
                style: const TextStyle(fontSize: 14, fontFamily: 'NunitoSans'),
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Display suggestion if available
            if (suggestion.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFE05D2B),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'NunitoSans',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Display keywords if available
            if (keywords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    keywords
                        .split(',')
                        .map((keyword) => keyword.trim())
                        .where((keyword) => keyword.isNotEmpty)
                        .map(
                          (keyword) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$keyword',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'NunitoSans',
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'senang':
        return Colors.green;
      case 'sedih':
        return Colors.blue;
      case 'marah':
        return Colors.red;
      case 'takut':
        return Colors.purple;
      default:
        return const Color(0xFFE05D2B); // Default orange-ish color
    }
  }
}
