// lib/presentation/widgets/modulation_graph/modulation_graph.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';

class ModulationGraph extends StatelessWidget {
  final List<double> pitchData;
  final double height;
  final Color lineColor;

  const ModulationGraph({
    super.key,
    required this.pitchData,
    this.height = 100,
    this.lineColor = AppColors.goldRoyal,
  });

  @override
  Widget build(BuildContext context) {
    if (pitchData.isEmpty) {
      return _buildEmptyState();
    }

    final spots = pitchData.asMap().entries.map(
      (e) => FlSpot(e.key.toDouble(), e.value),
    ).toList();

    final maxY = pitchData.reduce((a, b) => a > b ? a : b) + 10;
    final minY = (pitchData.reduce((a, b) => a < b ? a : b) - 10).clamp(0.0, double.infinity);

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.borderDark,
              strokeWidth: 0.5,
            ),
            drawVerticalLine: false,
          ),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    lineColor.withOpacity(0.3),
                    lineColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 50),
        curve: Curves.linear,
      ),
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq, color: AppColors.textMuted, size: 28),
            const SizedBox(height: 4),
            const Text(
              'Waiting for voice...',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
