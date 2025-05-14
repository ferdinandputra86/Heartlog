import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Notes extends StatelessWidget {
  final String emotion;
  final String keywords;
  final String suggestion;
  final String imagePath;
  final String? text;
  final DateTime? date;

  const Notes({
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
                          color: const Color(0xFFFD745A).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          emotion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFD745A),
                          ),
                        ),
                      ),
                      if (date != null) ...[
                        const SizedBox(width: 10),
                        _buildCompactDateDisplay(date!),
                      ],
                    ],
                  ),
                ),
                // Emotion image on the right
                Image.asset(
                  imagePath,
                  width: 32,
                  height: 32,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 32,
                      color: Colors.grey,
                    );
                  },
                ),
              ],
            ),

            if (text != null) ...[
              const SizedBox(height: 12),
              Text(
                text!,
                style: const TextStyle(fontSize: 16),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            if (suggestion.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECDF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Color(0xFFFD745A),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Compact date display for next to emotion
  Widget _buildCompactDateDisplay(DateTime dateTime) {
    // Format date: "14 May"
    final String formattedDate = DateFormat('d MMM').format(dateTime);

    // Format time: "3:30 PM"
    final String formattedTime = DateFormat('h:mm a').format(dateTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_note, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 1, height: 12, color: Colors.grey.shade300),
          const SizedBox(width: 6),
          Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            formattedTime,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
