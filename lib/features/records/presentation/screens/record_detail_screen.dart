import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../shared/models/freight_record.dart';
import '../../../../shared/providers/records_provider.dart';
import 'add_record_screen.dart';

class RecordDetailScreen extends StatelessWidget {
  const RecordDetailScreen({super.key, required this.record});
  final FreightRecord record;

  @override
  Widget build(BuildContext context) {
    final freight = record.calculatedFreight;
    final isNegative = freight < 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(record.truckNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AddRecordScreen(existingRecord: record),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Freight summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    isNegative ? AppColors.errorLight : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (isNegative ? AppColors.error : AppColors.primary)
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text('Total Freight',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(
                    AppUtils.formatCurrencyWithSign(freight),
                    style: AppTextStyles.displayLarge.copyWith(
                      color: isNegative ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(record.status),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow('Date', AppUtils.formatDate(record.date)),
                  _Divider(),
                  _DetailRow('Truck Number', record.truckNumber),
                  _Divider(),
                  _DetailRow('Driver / Party', record.driverName),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quantity', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _AmountItem(
                          label: 'Actual Qty',
                          value: '${record.quantity.toStringAsFixed(1)} T',
                        ),
                      ),
                      Expanded(
                        child: _AmountItem(
                          label: 'Challan Qty',
                          value:
                              '${record.challanQuantity.toStringAsFixed(1)} T',
                        ),
                      ),
                      Expanded(
                        child: _AmountItem(
                          label: 'Rate',
                          value: '₹${record.rate.toStringAsFixed(0)}/T',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Financial Breakdown',
                      style: AppTextStyles.titleMedium),
                  const SizedBox(height: 12),
                  _FinanceRow('Gross Freight',
                      AppUtils.formatCurrency(record.quantity * record.rate),
                      isPositive: true),
                  _FinanceRow(
                      'Diesel', '- ${AppUtils.formatCurrency(record.diesel)}',
                      isPositive: false),
                  _FinanceRow(
                      'Advance', '- ${AppUtils.formatCurrency(record.advance)}',
                      isPositive: false),
                  _FinanceRow('Unloading',
                      '- ${AppUtils.formatCurrency(record.unloading)}',
                      isPositive: false),
                  _FinanceRow('Short Amount',
                      '- ${AppUtils.formatCurrency(record.shortAmount)}',
                      isPositive: false),
                  const Divider(height: 20),
                  _FinanceRow(
                    'Net Freight',
                    AppUtils.formatCurrencyWithSign(freight),
                    isPositive: !isNegative,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RecordStatus status) {
    final isPending = status == RecordStatus.pending;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isPending ? AppColors.errorLight : AppColors.successLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending ? AppColors.error : AppColors.success,
        ),
      ),
      child: Text(
        isPending ? 'Pending' : 'Completed',
        style: AppTextStyles.labelMedium.copyWith(
          color: isPending ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete record for ${record.truckNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<RecordsProvider>().deleteRecord(record.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close detail screen
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 20, color: AppColors.divider);
}

class _AmountItem extends StatelessWidget {
  const _AmountItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value,
            style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
      ],
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow(this.label, this.value,
      {required this.isPositive, this.isBold = false});
  final String label;
  final String value;
  final bool isPositive;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isBold
                  ? AppTextStyles.titleMedium
                  : AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style:
                (isBold ? AppTextStyles.titleMedium : AppTextStyles.bodyMedium)
                    .copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: isBold ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
