import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:heartlog/diary_storage.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
  final DiaryStorage _diaryStorage = DiaryStorage();
  List<DiaryEntry> _entries = [];
  Map<String, int> _emotionCounts = {};
  Map<int, double> _dailyMoodScores = {};
  Map<int, double> _monthlyMoodScores = {};
  @override
  void initState() {
    super.initState();
    _loadEntries();

    // Listen to entry changes
    _diaryStorage.entriesStream.listen((entries) {
      if (mounted) {
        setState(() {
          _processEntries(entries);
        });
      }
    });
  }

  void _loadEntries() {
    _entries = _diaryStorage.getEntriesByDate();
    _processEntries(_entries);
  }

  void _processEntries(List<DiaryEntry> entries) {
    _entries = entries;
    // Count emotions
    _emotionCounts = {};
    for (var entry in entries) {
      // Use a fallback value if emotion is empty or null
      String emotion =
          entry.emotion.trim().isNotEmpty ? entry.emotion : "Unknown";
      _emotionCounts[emotion] = (_emotionCounts[emotion] ?? 0) + 1;
    }

    // Calculate daily mood scores for the past week
    _dailyMoodScores = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayEntries =
          entries
              .where(
                (entry) =>
                    entry.date.year == day.year &&
                    entry.date.month == day.month &&
                    entry.date.day == day.day,
              )
              .toList();

      if (dayEntries.isNotEmpty) {
        // Simple scoring: Senang=5, default=3
        double dayScore = 0;
        for (var entry in dayEntries) {
          switch (entry.emotion) {
            case 'Senang':
              dayScore += 5;
              break;
            case 'Marah':
              dayScore += 2;
              break;
            case 'Sedih':
              dayScore += 1;
              break;
            case 'Takut':
              dayScore += 1;
              break;
            default:
              dayScore += 3;
          }
        }
        _dailyMoodScores[i] = dayScore / dayEntries.length;
      } else {
        _dailyMoodScores[i] = 0; // No entries for this day
      }
    }

    // Calculate monthly mood scores for the past 4 months
    _monthlyMoodScores = {};
    for (int i = 3; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthEntries =
          entries
              .where(
                (entry) =>
                    entry.date.year == month.year &&
                    entry.date.month == month.month,
              )
              .toList();

      if (monthEntries.isNotEmpty) {
        // Simple scoring: Senang=80, default=50
        double monthScore = 0;
        for (var entry in monthEntries) {
          switch (entry.emotion) {
            case 'Senang':
              monthScore += 80;
              break;
            case 'Marah':
              monthScore += 30;
              break;
            case 'Sedih':
              monthScore += 20;
              break;
            case 'Takut':
              monthScore += 40;
              break;
            default:
              monthScore += 50;
          }
        }
        _monthlyMoodScores[i] = monthScore / monthEntries.length;
      } else {
        _monthlyMoodScores[i] = 0; // No entries for this month
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Emotional Journey'),
        backgroundColor: Colors.orangeAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('This Week\'s Emotions'),
            const SizedBox(height: 8),
            _buildPieChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Your Mood Journey'),
            const SizedBox(height: 8),
            _buildLineChart(),
            const SizedBox(height: 24),
            _buildSectionTitle('Your Frequent Feelings'),
            const SizedBox(height: 8),
            _buildFrequentFeelings(),
            const SizedBox(height: 24),
            _buildSectionTitle('Monthly Insights'),
            const SizedBox(height: 8),
            _buildBarChart(),
            // Add extra padding at the bottom to prevent navbar overlap
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPieChart() {
    if (_emotionCounts.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No diary entries available yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } // Calculate total for percentage
    final total = _emotionCounts.values.fold(0, (sum, count) => sum + count);

    if (total == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No valid emotion data found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Generate pie chart sections
    List<PieChartSectionData> sections = [];
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
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
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          // Remove the badgeWidget to avoid text overlap
          badgeWidget: null,
          badgePositionPercentageOffset: 0,
        ),
      );
      colorIndex++;
    } // Create a list of emotions to display in the legend
    final emotionsInChart = _emotionCounts.keys.toList();

    return Container(
      height: 340, // Increased height to accommodate the legend
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
                sectionsSpace: 3,
                centerSpaceRadius: 40,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    // Can be used for interactive feedback
                  },
                ),
                centerSpaceColor: Colors.white,
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
                          style: const TextStyle(
                            fontSize: 12,
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
      return const Center(child: Text('No diary entries available yet'));
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
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFFFF7643),
              barWidth: 4,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 6,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFFFF7643),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF7643).withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentFeelings() {
    if (_emotionCounts.isEmpty) {
      return const Center(child: Text('No diary entries available yet'));
    }

    // Calculate total for percentage
    final total = _emotionCounts.values.fold(0, (sum, count) => sum + count);

    // Take top 3 emotions
    final colors = [Colors.redAccent, Colors.orangeAccent, Colors.pinkAccent];
    final topEmotions =
        _emotionCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(topEmotions.length > 3 ? 3 : topEmotions.length, (
        index,
      ) {
        final emotion = topEmotions[index].key;
        final count = topEmotions[index].value;
        final percentage = ((count / total) * 100).round();
        return _buildFeelingCard(
          emotion,
          '$percentage%',
          colors[index % colors.length],
        );
      }),
    );
  }

  Widget _buildFeelingCard(String feeling, String percentage, Color color) {
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
      width: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            feeling,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              percentage,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (_entries.isEmpty) {
      return const Center(child: Text('No diary entries available yet'));
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
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.pinkAccent,
      Colors.amberAccent,
    ];

    // Create bar groups for the chart
    List<BarChartGroupData> barGroups = [];
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
              width: 20,
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
      height: 250,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
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
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
        ),
      ),
    );
  }
}
