import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/providers/records_provider.dart';

class RecordsFilterBar extends StatelessWidget {
  const RecordsFilterBar({super.key});

  static const _filters = [
    (RecordFilter.all, 'All'),
    (RecordFilter.pending, 'Pending'),
    (RecordFilter.completed, 'Completed'),
    (RecordFilter.profit, 'Profit'),
    (RecordFilter.loss, 'Loss'),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordsProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((entry) {
              final (filter, label) = entry;
              final isSelected = provider.filter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => provider.setFilter(filter),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
