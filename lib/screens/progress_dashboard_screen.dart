import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../helpers/app_colors.dart';
import '../helpers/database_helper.dart';

class ProgressDashboardScreen extends StatefulWidget {
  final bool embedded;
  const ProgressDashboardScreen({super.key, this.embedded = false});
  @override State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _recent = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final s = await DatabaseHelper.instance.getProgressStats();
    final r = await DatabaseHelper.instance.getRecentRecordings(7);
    if (mounted) setState(() { _stats = s; _recent = r; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
      ? const Center(child: CircularProgressIndicator(color: AppColors.purpleLight))
      : SingleChildScrollView(padding: const EdgeInsets.all(18), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.embedded) ...[
              const Text('PROGRESS', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 11, color: AppColors.textMuted, letterSpacing: 2)),
              const SizedBox(height: 12),
            ],
            // Stats grid
            Row(children: [
              _StatCard('${_stats['total_recordings'] ?? 0}', 'Sessions', Icons.mic_rounded, AppColors.purpleLight),
              const SizedBox(width: 10),
              _StatCard('${((_stats['avg_speaking_speed'] ?? 0.0)).toStringAsFixed(0)} WPM', 'Avg Speed', Icons.speed, AppColors.accentBlue),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _StatCard('${((_stats['avg_filler_words'] ?? 0.0)).toStringAsFixed(1)}', 'Avg Fillers', Icons.warning_amber_rounded, AppColors.amberWarning),
              const SizedBox(width: 10),
              _StatCard('${((_stats['avg_word_count'] ?? 0.0)).toStringAsFixed(0)}', 'Avg Words', Icons.text_fields, AppColors.matrixGreen),
            ]),
            const SizedBox(height: 28),

            if (_recent.isEmpty)
              Container(padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderDark)),
                child: Center(child: Column(children: [
                  Icon(Icons.bar_chart, size: 48, color: AppColors.textMuted.withOpacity(0.4)),
                  const SizedBox(height: 12),
                  const Text('No recordings yet', style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 14, color: AppColors.textMuted)),
                  const Text('Start recording to see your progress!', style: TextStyle(
                      fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
                ])))
            else ...[
              // Speed chart
              _chartCard(
                title: 'Speaking Speed — last 7 recordings',
                chart: SizedBox(height: 180, child: LineChart(LineChartData(
                  gridData: FlGridData(show: true,
                    getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.borderDark, strokeWidth: 0.5),
                    getDrawingVerticalLine: (_) => const FlLine(color: AppColors.borderDark, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 38,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                      getTitlesWidget: (v, _) => Text('${v.toInt()+1}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: true,
                    border: Border.all(color: AppColors.borderDark)),
                  lineBarsData: [LineChartBarData(
                    spots: _recent.reversed.toList().asMap().entries.map((e) =>
                      FlSpot(e.key.toDouble(), (e.value['speaking_speed'] ?? 0.0).toDouble())).toList(),
                    isCurved: true, color: AppColors.purpleLight, barWidth: 2.5,
                    dotData: FlDotData(show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4, color: AppColors.purpleLight,
                          strokeWidth: 1.5, strokeColor: AppColors.cardDark)),
                    belowBarData: BarAreaData(show: true,
                      gradient: LinearGradient(colors: [
                        AppColors.purpleLight.withOpacity(0.22),
                        AppColors.purpleLight.withOpacity(0),
                      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  )],
                ))),
              ),
              const SizedBox(height: 16),

              // Fillers chart
              _chartCard(
                title: 'Filler Words — last 7 recordings',
                chart: SizedBox(height: 180, child: BarChart(BarChartData(
                  gridData: FlGridData(show: true,
                    getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.borderDark, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                      getTitlesWidget: (v, _) => Text('${v.toInt()}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,
                      getTitlesWidget: (v, _) => Text('${v.toInt()+1}',
                        style: const TextStyle(fontFamily: 'Outfit', fontSize: 10, color: AppColors.textMuted)))),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false))),
                  borderData: FlBorderData(show: true, border: Border.all(color: AppColors.borderDark)),
                  barGroups: _recent.reversed.toList().asMap().entries.map((e) =>
                    BarChartGroupData(x: e.key, barRods: [BarChartRodData(
                      toY: (e.value['filler_word_count'] ?? 0).toDouble(),
                      color: AppColors.amberWarning, width: 18,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    )])).toList(),
                ))),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ));

    if (widget.embedded) return body;
    return Scaffold(backgroundColor: AppColors.obsidian,
      appBar: AppBar(title: const Text('PROGRESS')), body: body);
  }

  Widget _chartCard({required String title, required Widget chart}) =>
    Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontFamily: 'Outfit',
            fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        chart,
      ]));
}

class _StatCard extends StatelessWidget {
  final String value, title; final IconData icon; final Color color;
  const _StatCard(this.value, this.title, this.icon, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(height: 8),
      Text(value, style: TextStyle(fontFamily: 'Outfit',
          fontSize: 20, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 4),
      Text(title, textAlign: TextAlign.center, style: const TextStyle(
          fontFamily: 'Outfit', fontSize: 11, color: AppColors.textMuted)),
    ]),
  ));
}
