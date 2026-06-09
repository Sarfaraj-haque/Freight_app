import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.borderColor,
  });

  final String title;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineLarge.copyWith(
              color: valueColor ?? AppColors.primary,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle ?? '',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}
