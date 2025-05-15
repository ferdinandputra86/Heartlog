import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heartlog/models/diary_entry.dart';
import 'package:heartlog/controllers/statistic/statistic_controller.dart';
import 'package:heartlog/constants/index.dart';
import 'package:google_fonts/google_fonts.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final StatisticController _statisticController = StatisticController();
  List<DiaryEntry> _entries = [];
  Map<String, int> _emotionCounts = {};
  Map<int, double> _dailyMoodScores = {};
  Map<int, double> _monthlyMoodScores = {};

  @override
  void initState() {
    super.initState();
    _loadEntries();

    // Listen to entry changes
    _statisticController.entriesStream.listen((entries) {
      if (mounted) {
        setState(() {
          _processEntries(entries);
        });
      }
    });
  }

  void _loadEntries() {
    _statisticController.loadEntries();
    _entries = _statisticController.entries;
    _emotionCounts = _statisticController.emotionCounts;
    _dailyMoodScores = _statisticController.dailyMoodScores;
    _monthlyMoodScores = _statisticController.monthlyMoodScores;
  }

  void _processEntries(List<DiaryEntry> entries) {
    setState(() {
      _entries = entries;
      _statisticController.loadEntries();
      _emotionCounts = _statisticController.emotionCounts;
      _dailyMoodScores = _statisticController.dailyMoodScores;
      _monthlyMoodScores = _statisticController.monthlyMoodScores;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Your Emotional Journey',
                    style: AppTextStyles.headingLarge.copyWith(
                      fontSize: isSmallScreen ? 22 : 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Weekly Emotions', isSmallScreen),
                  const SizedBox(height: 8),
                  _buildPieChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Mood Journey', isSmallScreen),
                  const SizedBox(height: 8),
                  _buildLineChart(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Frequent Feelings', isSmallScreen),
                  const SizedBox(height: 8),
                  _buildFrequentFeelings(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Monthly Insights', isSmallScreen),
                  const SizedBox(height: 8),
                  _buildBarChart(),
                  // Add extra padding at the bottom
                  const SizedBox(height: 100),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper methods for building chart sections
  Widget _buildSectionTitle(String title, [bool isSmallScreen = false]) {
    return Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(
        fontSize: isSmallScreen ? 16 : 18,
      ),
    );
  }

  Widget _buildPieChart() {
    if (_emotionCounts.isEmpty) {
      return _buildEmptyDataContainer('No diary entries available');
    }

    // Calculate total for percentage
    final total = _emotionCounts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return _buildEmptyDataContainer('No valid emotion data found');
    }

    // Generate pie chart sections
    List<PieChartSectionData> sections = [];
    final colors = [
      AppColors.emotionHappy,
      AppColors.emotionAngry,
      AppColors.emotionSad,
      AppColors.emotionFear,
    ];
    int colorIndex = 0;

    for (var entry in _emotionCounts.entries) {
      final percentage = (entry.value / total * 100).round();
      // Use custom emoji for emotions
      String emoji = '';
      switch (entry.key) {
        case 'Senang':
          emoji = '😄';
          break;
        case 'Sedih':
          emoji = '😢';
          break;
        case 'Marah':
          emoji = '😡';
          break;
        case 'Takut':
          emoji = '😨';
          break;
        default:
          emoji = '🙂';
      }
      sections.add(
        PieChartSectionData(
          value: entry.value.toDouble(),
          color: colors[colorIndex % colors.length],
          title: '$emoji\n$percentage%',
          titlePositionPercentageOffset: 0.55,
          radius: MediaQuery.of(context).size.width < 360 ? 50 : 60,
          titleStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
      colorIndex++;
    }

    // Create a list of emotions to display in the legend
    final emotionsInChart = _emotionCounts.keys.toList();

    return Container(
      height: 340, // Increased height to accommodate the legend
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // The chart itself
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: MediaQuery.of(context).size.width < 360 ? 2 : 3,
                centerSpaceRadius:
                    MediaQuery.of(context).size.width < 360 ? 30 : 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Can be used for interactive feedback
                  },
                ),
                centerSpaceColor: AppColors.white,
              ),
            ),
          ),

          // Legend below the chart
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                emotionsInChart.length > 4 ? 4 : emotionsInChart.length,
                (index) {
                  final emotion = emotionsInChart[index];
                  String emoji;
                  switch (emotion) {
                    case 'Senang':
                      emoji = '😄';
                      break;
                    case 'Sedih':
                      emoji = '😢';
                      break;
                    case 'Marah':
                      emoji = '😡';
                      break;
                    case 'Takut':
                      emoji = '😨';
                      break;
                    default:
                      emoji = '🙂';
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[index % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$emoji $emotion',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    if (_entries.isEmpty) {
      return _buildEmptyDataContainer('No diary entries available');
    }

    // Get the day names for the past week
    final now = DateTime.now();
    final days = List<String>.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1];
    });

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      // Use the mood score or 0 if not available
      double score = _dailyMoodScores[6 - i] ?? 0;
      spots.add(FlSpot(i.toDouble(), score));
    }
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Container(
      height: isSmallScreen ? 200 : 220,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 8 : 10,
        horizontal: isSmallScreen ? 3 : 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0 && value >= 0 && value <= 5) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        days[value.toInt()],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: AppColors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentFeelings() {
    if (_emotionCounts.isEmpty) {
      return _buildEmptyDataContainer('No diary entries available');
    }

    // Calculate total for percentage
    final total = _emotionCounts.values.fold(0, (sum, count) => sum + count);

    // Take top 3 emotions
    final colors = [
      AppColors.emotionHappy,
      AppColors.emotionAngry,
      AppColors.emotionSad,
    ];
    final topEmotions =
        _emotionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isSmallScreen = constraints.maxWidth < 360;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(
            topEmotions.length > 3 ? 3 : topEmotions.length,
            (index) {
              final emotion = topEmotions[index].key;
              final count = topEmotions[index].value;
              final percentage = ((count / total) * 100).round();
              return _buildFeelingCard(
                emotion,
                '$percentage%',
                colors[index % colors.length],
                isSmallScreen,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFeelingCard(
    String feeling,
    String percentage,
    Color color, [
    bool isSmallScreen = false,
  ]) {
    // Use emoji based on feeling
    String emoji;
    switch (feeling) {
      case 'Senang':
        emoji = '😄';
        break;
      case 'Sedih':
        emoji = '😢';
        break;
      case 'Marah':
        emoji = '😡';
        break;
      case 'Takut':
        emoji = '😨';
        break;
      default:
        emoji = '🙂';
    }

    return Container(
      width: isSmallScreen ? 90 : 100,
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 32 : 40)),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            feeling,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 12 : 14,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isSmallScreen ? 3 : 4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: isSmallScreen ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              percentage,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 10 : 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_entries.isEmpty) {
      return _buildEmptyDataContainer('No diary entries available');
    }

    // Get the month names for the past 4 months
    final now = DateTime.now();
    final months =
        List<String>.generate(4, (i) {
          final month = now.month - i;
          final adjustedMonth = month <= 0 ? month + 12 : month;
          return [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ][adjustedMonth - 1];
        }).reversed.toList();

    // Colors for the bars
    final colors = [
      AppColors.emotionHappy,
      AppColors.emotionAngry,
      AppColors.emotionSad,
      AppColors.emotionFear,
    ];

    // Create bar groups for the chart
    List<BarChartGroupData> barGroups = [];
    final bool isSmallScreen = MediaQuery.of(context).size.width < 360;
    final double barWidth = isSmallScreen ? 16 : 20;

    for (int i = 0; i < 4; i++) {
      // Use the monthly mood score or 0 if not available
      double score = _monthlyMoodScores[3 - i] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: score,
              color: colors[i % colors.length],
              width: barWidth,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: isSmallScreen ? 220 : 250,
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 8 : 10,
        horizontal: isSmallScreen ? 3 : 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine:
                (value) => FlLine(
                  color: Colors.grey.withOpacity(0.2),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 25 == 0 && value >= 0 && value <= 100) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value >= 0 && value < months.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        months[value.toInt()],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }

  Widget _buildEmptyDataContainer(String message) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;
        return Container(
          height: isSmallScreen ? 180 : 200,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
