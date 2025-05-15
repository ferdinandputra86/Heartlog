import 'package:flutter/material.dart';
import 'package:heartlog/controllers/write/write_controller.dart';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/services/diary_storage_service.dart';

class WriteScreen extends StatefulWidget {
  final String? initialEmotion;

  const WriteScreen({super.key, this.initialEmotion});

  @override
  State<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  late String selectedEmotion;
  final TextEditingController _textController = TextEditingController();
  late final WriteController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WriteController();
    // Initialize with passed emotion or default to Senang
    selectedEmotion = widget.initialEmotion ?? 'Senang';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1E0),
      appBar: AppBar(
        title: const Text(
          'Tulis Diari',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
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
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Hitung ukuran ikon berdasarkan lebar layar
                        final double iconSize =
                            constraints.maxWidth < 360 ? 50 : 64;
                        final double iconTextSize =
                            constraints.maxWidth < 360 ? 12 : 14;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildEmotionOption(
                              'Senang',
                              'assets/Emotion/senang.png',
                              Colors.green,
                              iconSize,
                              iconTextSize,
                            ),
                            _buildEmotionOption(
                              'Sedih',
                              'assets/Emotion/sedih.png',
                              Colors.blue,
                              iconSize,
                              iconTextSize,
                            ),
                            _buildEmotionOption(
                              'Takut',
                              'assets/Emotion/takut.png',
                              Colors.purple,
                              iconSize,
                              iconTextSize,
                            ),
                            _buildEmotionOption(
                              'Marah',
                              'assets/Emotion/marah.png',
                              Colors.red,
                              iconSize,
                              iconTextSize,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ceritakan harimu:',
                      style: TextStyle(
                        fontSize:
                            MediaQuery.of(context).size.width < 360 ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        // Sesuaikan tinggi maksimum berdasarkan ukuran layar
                        maxHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines:
                            null, // Biarkan teks mengatur tinggi secara dinamis
                        minLines: 6, // Minimal 6 baris
                        decoration: const InputDecoration(
                          hintText: 'Tuliskan cerita harimu di sini...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.all(16),
                          hintStyle: TextStyle(fontFamily: 'NunitoSans'),
                        ),
                        style: const TextStyle(fontFamily: 'NunitoSans'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ), // Save button - fixed at bottom
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 16),
              constraints: const BoxConstraints(
                maxWidth: 500,
              ), // Batasi lebar maksimal
              child: ElevatedButton(
                onPressed: () => _saveEntry(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfffd745a),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 360 ? 16 : 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionOption(
    String emotion,
    String imagePath,
    Color color, [
    double containerSize = 64,
    double fontSize = 14,
  ]) {
    final bool isSelected = selectedEmotion == emotion;
    final double imageSize = containerSize * 0.8; // 80% of container size

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedEmotion = emotion;
        });
      },
      child: Column(
        children: [
          Container(
            width: containerSize,
            height: containerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: Center(
              child: Image.asset(
                imagePath,
                width: imageSize,
                height: imageSize,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.mood, size: imageSize, color: color);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            emotion,
            style: TextStyle(
              color: isSelected ? color : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'NunitoSans',
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  void _saveEntry(BuildContext context) {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan tulis sesuatu tentang harimu terlebih dahulu.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get suggestion based on emotion
    final suggestion = _controller.getSuggestionForEmotion(selectedEmotion);

    // Create a new diary entry
    final entry = DiaryEntry(
      text: _textController.text.trim(),
      date: DateTime.now(),
      emotion: selectedEmotion,
      suggestion: suggestion,
      imagePath: _getEmotionImagePath(selectedEmotion),
    );

    // Save entry using controller
    _controller
        .saveDiaryEntry(entry)
        .then((_) {
          // Close the screen and return success
          Navigator.pop(context, true);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  String _getEmotionImagePath(String emotion) {
    switch (emotion) {
      case 'Senang':
        return 'assets/Emotion/senang.png';
      case 'Sedih':
        return 'assets/Emotion/sedih.png';
      case 'Takut':
        return 'assets/Emotion/takut.png';
      case 'Marah':
        return 'assets/Emotion/marah.png';
      default:
        return 'assets/Emotion/senang.png';
    }
  }
}
