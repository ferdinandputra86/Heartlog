import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:heartlog/diary_storage.dart';

class Write extends StatefulWidget {
  const Write({super.key});

  @override
  State<Write> createState() => _WriteState();
}

class _WriteState extends State<Write> {
  String selectedEmotion = 'Senang';
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E0),
      appBar: AppBar(
        title: const Text('Tulis Diary'),
        backgroundColor: const Color(0xfffd745a),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content area - scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bagaimana perasaanmu hari ini?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildEmotionOption(
                          'Senang',
                          'assets/Emotion/senang.png',
                        ),
                        _buildEmotionOption(
                          'Sedih',
                          'assets/Emotion/sedih.png',
                        ),
                        _buildEmotionOption(
                          'Takut',
                          'assets/Emotion/takut.png',
                        ),
                        _buildEmotionOption(
                          'Marah',
                          'assets/Emotion/marah.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Tulis tentang harimu:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Ceritakan tentang harimu...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    // Add padding at the bottom to ensure everything is visible
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Button at the bottom, outside of scroll view
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfffd745a),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Save to DiaryStorage
                  final newDiaryEntry = DiaryEntry(
                    text: _textController.text,
                    date: DateTime.now(),
                    emotion: selectedEmotion,
                    suggestion: _getSuggestion(selectedEmotion),
                    imagePath: _getEmotionImagePath(selectedEmotion),
                  );
                  DiaryStorage().addEntry(newDiaryEntry);
                  if (kDebugMode) {
                    print(
                      "Entry saved to DiaryStorage: ${DiaryStorage().getEntries().length} entries",
                    );
                  }

                  // Return true to indicate an entry was added - this will trigger a refresh
                  Navigator.pop(context, true);

                  // Show a confirmation message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Diary entry saved!')),
                  );
                },
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionOption(String emotion, String imagePath) {
    final isSelected = selectedEmotion == emotion;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmotion = emotion;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xfffd745a) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              imagePath,
              width: 56,
              height: 56,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, size: 56, color: Colors.red);
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emotion,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? const Color(0xfffd745a) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  String _getEmotionImagePath(String emotion) {
    // Use the helper method from DiaryStorage
    return DiaryStorage.getImagePathForEmotion(emotion);
  }

  String _getSuggestion(String emotion) {
    // Use the helper method from DiaryStorage
    return DiaryStorage.getSuggestionForEmotion(emotion);
  }
}
