import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Statistic extends StatefulWidget {
  const Statistic({super.key});

  @override
  State<Statistic> createState() => _StatisticState();
}

class _StatisticState extends State<Statistic> {
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
            const SizedBox(height: 16),
            _buildSectionTitle('Your Mood Journey'),
            const SizedBox(height: 8),
            _buildLineChart(),
            const SizedBox(height: 16),
            _buildSectionTitle('Your Frequent Feelings'),
            const SizedBox(height: 8),
            _buildFrequentFeelings(),
            const SizedBox(height: 16),
            _buildSectionTitle('Monthly Insights'),
            const SizedBox(height: 8),
            _buildBarChart(),
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
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.redAccent,
              title: 'Joy (40%)',
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.orangeAccent,
              title: 'Calm (30%)',
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.pinkAccent,
              title: 'Love (20%)',
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.amberAccent,
              title: 'Excited (10%)',
            ),
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];
                  return Text(days[value.toInt() % days.length]);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 4),
                FlSpot(1, 3),
                FlSpot(2, 5),
                FlSpot(3, 4),
                FlSpot(4, 6),
                FlSpot(5, 5),
                FlSpot(6, 4),
              ],
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequentFeelings() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeelingCard('Joy', '40%', Colors.redAccent),
        _buildFeelingCard('Calm', '30%', Colors.orangeAccent),
        _buildFeelingCard('Love', '20%', Colors.pinkAccent),
      ],
    );
  }

  Widget _buildFeelingCard(String feeling, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.sentiment_satisfied, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            feeling,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          Text(percentage, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const months = ['Jan', 'Feb', 'Mar', 'Apr'];
                  return Text(months[value.toInt() % months.length]);
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [BarChartRodData(toY: 80, color: Colors.redAccent)],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [BarChartRodData(toY: 70, color: Colors.orangeAccent)],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [BarChartRodData(toY: 90, color: Colors.pinkAccent)],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [BarChartRodData(toY: 60, color: Colors.amberAccent)],
            ),
          ],
        ),
      ),
    );
  }
}
