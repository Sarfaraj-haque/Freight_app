import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/models/freight_record.dart';

class StatusSelector extends StatelessWidget {
  const StatusSelector(
      {super.key, required this.status, required this.onChanged});
  final RecordStatus status;
  final ValueChanged<RecordStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: RecordStatus.values.map((s) {
        final isSelected = status == s;
        final isPending = s == RecordStatus.pending;
        final color = isPending ? AppColors.error : AppColors.success;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Completed',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? color : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
