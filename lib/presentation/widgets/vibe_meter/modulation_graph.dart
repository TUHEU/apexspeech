// lib/presentation/widgets/vibe_meter/modulation_graph.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ModulationGraph extends StatelessWidget {
  final List<double> data;
  final double height;
  final Color color;

  const ModulationGraph({
    super.key,
    required this.data,
    this.height = 90,
    this.color  = AppColors.goldRoyal,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'Waiting for voice…',
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList();

    final maxY = data.reduce((a, b) => a > b ? a : b) + 15;
    final minY = (data.reduce((a, b) => a < b ? a : b) - 15)
        .clamp(0.0, double.infinity);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 3,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.borderDark,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots:          spots,
              isCurved:       true,
              curveSmoothness:0.4,
              color:          color,
              barWidth:       2.5,
              isStrokeCapRound: true,
              dotData:        const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.28),
                    color.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end:   Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 50),
      ),
    );
  }
}
