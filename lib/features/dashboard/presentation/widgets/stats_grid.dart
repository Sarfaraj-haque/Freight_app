import 'package:flutter/material.dart';
import 'package:freight_app/core/theme/app_colors.dart';
import 'package:freight_app/core/utils/app_utils.dart';

import '../../../../core/widgets/stat_card.dart';
import '../../../../shared/providers/records_provider.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, required this.provider});
  final RecordsProvider provider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Total Trips',
                    value: provider.totalTrips.toString(),
                    borderColor: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Pending',
                    value: provider.pendingCount.toString(),
                    subtitle: provider.pendingCount > 0
                        ? '${AppUtils.formatCurrency(provider.pendingOwed)} owed'
                        : null,
                    borderColor: AppColors.error,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Total Freight',
                    value:
                        AppUtils.formatCurrencyWithSign(provider.totalFreight),
                    subtitle: 'All entries combined',
                    borderColor: AppColors.primary,
                    valueColor: provider.totalFreight >= 0
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Total Diesel',
                    value: AppUtils.formatCurrency(provider.totalDiesel),
                    borderColor: AppColors.warning,
                    valueColor: AppColors.warning,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Total Weight',
                    value: AppUtils.formatWeight(provider.totalWeight),
                    subtitle: 'Coal lifted (tonnes)',
                    borderColor: AppColors.primary,
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: StatCard(
                    title: 'Avg / Trip',
                    value: provider.totalTrips == 0
                        ? '—'
                        : AppUtils.formatCurrencyWithSign(provider.avgPerTrip),
                    borderColor: AppColors.border,
                    valueColor: provider.avgPerTrip >= 0
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
