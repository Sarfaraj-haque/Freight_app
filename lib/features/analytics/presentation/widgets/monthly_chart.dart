import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class MonthlyChart extends StatelessWidget {
  const MonthlyChart({super.key, required this.monthlyData});
  final Map<String, double> monthlyData;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monthly Freight', style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          if (monthlyData.isEmpty)
            const SizedBox(
              height: 160,
              child: Center(
                child: Text('No data yet',
                    style: TextStyle(color: AppColors.textHint)),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    final sortedKeys = monthlyData.keys.toList()..sort();
    final barGroups = sortedKeys.asMap().entries.map((entry) {
      final value = monthlyData[entry.value]! / 1000;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: value >= 0 ? AppColors.primary : AppColors.error,
            width: 32,
            borderRadius: value >= 0
                ? const BorderRadius.vertical(top: Radius.circular(4))
                : const BorderRadius.vertical(bottom: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        barGroups: barGroups,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (v) => const FlLine(
            color: AppColors.divider,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= sortedKeys.length) return const SizedBox.shrink();
                final key = sortedKeys[index];
                final parts = key.split('-');
                return Text(
                  parts.length > 1
                      ? _monthAbbr(int.tryParse(parts[1]) ?? 1)
                      : key,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(0),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
              ),
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '₹${(rod.toY * 1000).toStringAsFixed(0)}',
                AppTextStyles.labelMedium.copyWith(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  String _monthAbbr(int month) {
    const months = [
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
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
