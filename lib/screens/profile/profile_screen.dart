import 'package:flutter/material.dart';
import 'package:heartlog/services/user_preferences_service.dart';
import 'package:heartlog/services/diary_storage_service.dart';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/constants/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DiaryStorageService _diaryStorage = DiaryStorageService();
  final UserPreferencesService _userPreferences = UserPreferencesService();
  late TextEditingController _nameController;
  late String _userName;
  late List<DiaryEntry> _entries = [];
  late String _entriesCount = '0';
  late String _uniqueMoods = '0';
  late String _weeksCount = '0';

  @override
  void initState() {
    super.initState();
    _userName = _userPreferences.userName;
    _nameController = TextEditingController(text: _userName);
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

    // Listen to changes in username
    _userPreferences.userNameStream.listen((newName) {
      if (mounted) {
        setState(() {
          _userName = newName;
          _nameController.text = newName;
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

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: const Color(0xFFFFE4D6));
  }

  Widget _buildStatistic(
    String value,
    String label, [
    bool isSmallScreen = false,
  ]) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
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
          color: isDestructive ? Colors.redAccent : AppColors.primary,
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

  Widget _buildAboutItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 15),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.black),
        ),
        centerTitle: true,
        leading: const SizedBox(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsif berdasarkan lebar layar
              final bool isSmallScreen = constraints.maxWidth < 360;
              final double avatarRadius = isSmallScreen ? 40 : 50;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Profile heart icon
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Icon(
                      Icons.favorite,
                      size: avatarRadius,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userName,
                    style: AppTextStyles.headingMedium.copyWith(
                      fontSize: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                    ), // Batasi lebar maksimum
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 16,
                      horizontal: isSmallScreen ? 12 : 20,
                    ),
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
                        _buildStatistic(
                          _entriesCount,
                          'Entries',
                          isSmallScreen,
                        ),
                        _buildVerticalDivider(),
                        _buildStatistic(_uniqueMoods, 'Moods', isSmallScreen),
                        _buildVerticalDivider(),
                        _buildStatistic(_weeksCount, 'Weeks', isSmallScreen),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFFFE4D6)),
                  const SizedBox(height: 16),
                  _buildSettingsOption(
                    Icons.person_outline,
                    'Account Settings',
                    () {
                      // Show dialog to change username with cute UI
                      _nameController.text =
                          _userName; // Pre-fill with current name
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
                                    Icon(
                                      Icons.edit,
                                      size: 50,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Ubah Nama Pengguna',
                                      style: AppTextStyles.headingSmall,
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan nama baru',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          borderSide: BorderSide(
                                            color: AppColors.primary,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 15,
                                            ),
                                      ),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: Text(
                                            'Batal',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            final newName =
                                                _nameController.text.trim();
                                            if (newName.isNotEmpty) {
                                              _userPreferences.setUserName(
                                                newName,
                                              );
                                              Navigator.pop(context);
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          child: const Text(
                                            'Simpan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      );
                    },
                  ),
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
                                          color: AppColors.primary.withOpacity(
                                            0.2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      Icon(
                                        Icons.favorite,
                                        size: 50,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'HeartLog',
                                    style: AppTextStyles.headingMedium.copyWith(
                                      color: AppColors.primary,
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
                                      color: AppColors.primaryLight.withOpacity(
                                        0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildAboutItem(
                                          icon: Icons.calendar_today,
                                          text:
                                              'Track your daily emotions and moods',
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
                                          text:
                                              'Reflect on your emotional journey',
                                        ),
                                        const SizedBox(height: 10),
                                        _buildAboutItem(
                                          icon: Icons.insights,
                                          text:
                                              'Identify patterns in your feelings',
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
                                      backgroundColor: AppColors.primary,
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
                  _buildSettingsOption(
                    Icons.delete_outline,
                    'Delete All Diaries',
                    () {
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
                    },
                    isDestructive: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Version 1.0',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
