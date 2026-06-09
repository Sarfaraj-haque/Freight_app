import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../shared/providers/records_provider.dart';
import '../../../records/presentation/screens/add_record_screen.dart';
import '../widgets/record_list_item.dart';
import '../widgets/stats_grid.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<RecordsProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: _DashboardHeader(),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: StatsGrid(provider: provider),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Recent Records',
                      actionLabel: 'See all',
                      onAction: () {
                        // Switch to records tab
                        final scaffold =
                            context.findAncestorStateOfType<State>();
                        if (scaffold != null) {
                          // navigate via shell index
                        }
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: provider.recentRecords.isEmpty
                      ? SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  const Icon(Icons.local_shipping_outlined,
                                      size: 56, color: AppColors.textHint),
                                  const SizedBox(height: 12),
                                  Text('No records yet',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: RecordListItem(
                                  record: provider.recentRecords[index]),
                            ),
                            childCount: provider.recentRecords.length,
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn1',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecordScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back,',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 2),
            const Text(
              AppConstants.hardcodedUserId,
              style: AppTextStyles.displayMedium,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Admin',
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
