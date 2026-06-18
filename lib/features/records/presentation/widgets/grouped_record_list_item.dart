import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/freight_record.dart';

class GroupedRecordListItem extends StatelessWidget {
  const GroupedRecordListItem({
    super.key,
    required this.title,
    required this.records,
    required this.onTap,
    this.isDriverGroup = false,
  });

  final String title;
  final List<FreightRecord> records;
  final VoidCallback onTap;
  final bool isDriverGroup;

  @override
  Widget build(BuildContext context) {
    final totalFreight =
        records.fold<double>(0, (sum, r) => sum + r.calculatedFreight);
    final totalQty = records.fold<double>(0, (sum, r) => sum + r.quantity);

    // For driver groups, we might want to show how many unique trucks they used
    final uniqueTrucks = records.map((r) => r.truckNumber).toSet().length;
    // For truck groups, we show the driver name
    final driverName = records.first.driverName;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDriverGroup
                              ? Icons.person_rounded
                              : Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          title,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${records.length}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _GroupField(
                label: isDriverGroup ? 'Trucks' : 'Driver',
                value: isDriverGroup
                    ? '$uniqueTrucks vehicle${uniqueTrucks > 1 ? 's' : ''}'
                    : AppUtils.truncate(driverName, 15),
              ),
              const SizedBox(width: 20),
              _GroupField(
                label: 'Total Qty',
                value: totalQty.toStringAsFixed(1),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Freight', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    AppUtils.formatCurrencyWithSign(totalFreight),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: totalFreight >= 0
                          ? AppColors.primary
                          : AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GroupField extends StatelessWidget {
  const _GroupField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }
}
