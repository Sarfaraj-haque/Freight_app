import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_utils.dart';

class FreightCalculatorBanner extends StatelessWidget {
  const FreightCalculatorBanner({super.key, required this.freight});
  final double freight;

  @override
  Widget build(BuildContext context) {
    final isNegative = freight < 0;
    final color = isNegative ? AppColors.error : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNegative ? AppColors.errorLight : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Calculated Freight',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            AppUtils.formatCurrencyWithSign(freight),
            style: AppTextStyles.displayMedium.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            '(qty × rate) - diesel - advance - unloading - shortAmount',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
