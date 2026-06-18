import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/freight_record.dart';
import '../screens/record_detail_screen.dart';

class RecordListItem extends StatelessWidget {
  const RecordListItem({super.key, required this.record});
  final FreightRecord record;

  @override
  Widget build(BuildContext context) {
    final isPending = record.status == RecordStatus.pending;
    final freight = record.calculatedFreight;

    return AppCard(
      borderColor: isPending ? AppColors.error : AppColors.success,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecordDetailScreen(record: record)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_shipping_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      record.truckNumber,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  AppUtils.formatDate(record.date),
                  style: AppTextStyles.bodySmall,
                ),
              ),
              // _StatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RecordField(
                label: 'Driver',
                value: AppUtils.truncate(record.driverName, 12),
              ),
              const SizedBox(width: 20),
              _RecordField(
                label: 'Qty (T)',
                value: record.quantity.toStringAsFixed(1),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Freight', style: AppTextStyles.bodySmall),
                  const SizedBox(height: 2),
                  Text(
                    AppUtils.formatCurrencyWithSign(freight),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: freight >= 0 ? AppColors.primary : AppColors.error,
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

class _RecordField extends StatelessWidget {
  const _RecordField({required this.label, required this.value});
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

// class _StatusBadge extends StatelessWidget {
//   const _StatusBadge({required this.status});
//   final RecordStatus status;
//
//   @override
//   Widget build(BuildContext context) {
//     final isPending = status == RecordStatus.pending;
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isPending ? AppColors.errorLight : AppColors.successLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isPending ? AppColors.error : AppColors.success,
//           width: 1,
//         ),
//       ),
//       child: Text(
//         isPending ? 'Pending' : 'Completed',
//         style: AppTextStyles.bodySmall.copyWith(
//           color: isPending ? AppColors.error : AppColors.success,
//           fontWeight: FontWeight.w600,
//           fontSize: 11,
//         ),
//       ),
//     );
//   }
// }
