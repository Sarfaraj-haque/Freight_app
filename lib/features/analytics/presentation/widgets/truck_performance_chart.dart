import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';

class TruckPerformanceChart extends StatelessWidget {
  const TruckPerformanceChart({super.key, required this.truckData});
  final Map<String, double> truckData;

  @override
  Widget build(BuildContext context) {
    final sorted = truckData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Truck Performance', style: AppTextStyles.titleLarge),
          const SizedBox(height: 20),
          if (top.isEmpty)
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
              child: _buildChart(top),
            ),
          if (top.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...top.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: AppTextStyles.titleMedium),
                      Text(
                        AppUtils.formatCurrencyWithSign(e.value),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: e.value >= 0
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildChart(List<MapEntry<String, double>> top) {
    final barGroups = top.asMap().entries.map((entry) {
      final value = entry.value.value / 1000;
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: value,
            color: value >= 0 ? AppColors.primary : AppColors.error,
            width: 28,
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
          getDrawingHorizontalLine: (v) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
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
                if (index >= top.length) return const SizedBox.shrink();
                final label = top[index].key;
                return Text(
                  label.length > 7 ? label.substring(0, 7) : label,
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 9),
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
      ),
    );
  }
}
