import 'package:flutter/material.dart';
import 'diary_storage.dart';
import 'profile_icon.dart';
import 'user_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final DiaryStorage _diaryStorage = DiaryStorage();
  final UserPreferences _userPreferences = UserPreferences();
  late String _userName;
  late List<DiaryEntry> _entries;
  late String _entriesCount;
  late String _uniqueMoods;
  late String _weeksCount;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userName = _userPreferences.userName;
    _loadStatistics();

    // Listen for changes in diary entries
    _diaryStorage.entriesStream.listen((entries) {
      if (mounted) {
        setState(() {
          _entries = entries;
          _updateStatistics();
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

  void _loadStatistics() {
    _entries = _diaryStorage.getEntries();
    _updateStatistics();
  }

  void _updateStatistics() {
    _entriesCount = _entries.length.toString();
    _uniqueMoods =
        _entries.isEmpty
            ? '0'
            : _entries.map((e) => e.emotion).toSet().length.toString();

    // Calculate weeks span
    if (_entries.isEmpty) {
      _weeksCount = '0';
    } else {
      // Sort entries by date
      final sortedEntries = List<DiaryEntry>.from(_entries)
        ..sort((a, b) => a.date.compareTo(b.date));

      final firstEntryDate = sortedEntries.first.date;
      final lastEntryDate = sortedEntries.last.date;

      // Calculate difference in weeks
      final difference = lastEntryDate.difference(firstEntryDate).inDays;
      final weeks = (difference / 7).ceil();
      _weeksCount = weeks.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        leading: const SizedBox(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Profile heart icon
            const HeartProfileIcon(size: 100),
            const SizedBox(height: 16),
            Text(
              _userName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatistic(_entriesCount, 'Entries'),
                  _buildVerticalDivider(),
                  _buildStatistic(_uniqueMoods, 'Moods'),
                  _buildVerticalDivider(),
                  _buildStatistic(_weeksCount, 'Weeks'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFFFE4D6)),
            const SizedBox(height: 16),
            _buildSettingsOption(Icons.person_outline, 'Account Settings', () {
              // Show dialog to change username with cute UI
              _nameController.text = _userName; // Pre-fill with current name
              showDialog(
                context: context,
                builder:
                    (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.edit,
                              size: 50,
                              color: Colors.orangeAccent,
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Change Your Name',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'New Username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: BorderSide(
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  borderSide: const BorderSide(
                                    color: Colors.orangeAccent,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person,
                                  color: Colors.orangeAccent,
                                ),
                                filled: true,
                                fillColor: Colors.orange.shade50,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 25,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  onPressed: () async {
                                    // Implement name change functionality
                                    if (_nameController.text.isNotEmpty) {
                                      await _userPreferences.setUserName(
                                        _nameController.text,
                                      );

                                      // Show success snackbar
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Name updated successfully',
                                            ),
                                            backgroundColor: Colors.green,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text(
                                    'Save',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            }),
            _buildSettingsOption(Icons.info_outline, 'About HeartLog', () {
              showDialog(
                context: context,
                builder:
                    (context) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const Icon(
                                  Icons.favorite,
                                  size: 50,
                                  color: Colors.orangeAccent,
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'HeartLog',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Your Happy Place',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  _buildAboutItem(
                                    icon: Icons.calendar_today,
                                    text: 'Track your daily emotions and moods',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAboutItem(
                                    icon: Icons.book,
                                    text:
                                        'Record meaningful moments in your life',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAboutItem(
                                    icon: Icons.psychology,
                                    text: 'Reflect on your emotional journey',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAboutItem(
                                    icon: Icons.insights,
                                    text: 'Identify patterns in your feelings',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                              'Your personal space to express and understand yourself ♥',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Got it!',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              );
            }),
            const SizedBox(height: 16),
            _buildSettingsOption(Icons.delete_outline, 'Delete All Diaries', () {
              // Confirmation dialog before deleting all diaries
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 10),
                          Text('Delete All Diaries'),
                        ],
                      ),
                      content: const Text(
                        'Are you sure you want to delete all your diary entries? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            // Implement diary deletion functionality
                            await _diaryStorage.deleteAllEntries();

                            // Update statistics immediately
                            setState(() {
                              _loadStatistics();
                            });

                            // Close the dialog and show success message
                            Navigator.pop(context);

                            // Show a confirmation message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All diary entries have been deleted',
                                ),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: const Text('Delete All'),
                        ),
                      ],
                    ),
              );
            }, isDestructive: true),
            const SizedBox(height: 24),
            const Text(
              'Version 1.0',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.orangeAccent, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFFFE4D6));
  }

  Widget _buildStatistic(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.orangeAccent,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
