import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.total,
    required this.pending,
    required this.completed,
  });

  final int total;
  final int pending;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatItem(value: total, label: 'Records')),
        const SizedBox(width: 10),
        Expanded(child: _StatItem(value: pending, label: 'Pending')),
        const SizedBox(width: 10),
        Expanded(child: _StatItem(value: completed, label: 'Completed')),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: AppTextStyles.headlineLarge,
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
