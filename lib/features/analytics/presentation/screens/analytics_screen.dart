import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../shared/providers/records_provider.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/truck_performance_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<RecordsProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overview', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Trips',
                        value: provider.totalTrips.toString(),
                        borderColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Profitable',
                        value: provider.profitableCount.toString(),
                        subtitle:
                            '${provider.totalTrips == 0 ? 0 : (provider.profitableCount / provider.totalTrips * 100).toStringAsFixed(0)}% of trips',
                        borderColor: AppColors.success,
                        valueColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Freight',
                        value: AppUtils.formatCurrencyWithSign(
                            provider.totalFreight),
                        borderColor: AppColors.primary,
                        valueColor: provider.totalFreight >= 0
                            ? AppColors.primary
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Total Diesel',
                        value: AppUtils.formatCurrency(provider.totalDiesel),
                        borderColor: AppColors.warning,
                        valueColor: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Monthly Profit/Loss (in ₹1000s)',
                    style: AppTextStyles.headlineMedium),
                const SizedBox(height: 14),
                MonthlyChart(monthlyData: provider.monthlyFreight),
                const SizedBox(height: 28),
                const Text('Top Trucks by Freight (₹1000s)',
                    style: AppTextStyles.headlineMedium),
                const SizedBox(height: 14),
                TruckPerformanceChart(truckData: provider.truckFreight),
              ],
            ),
          );
        },
      ),
    );
  }
}
