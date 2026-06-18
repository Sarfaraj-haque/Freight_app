import 'package:flutter/material.dart';
import 'package:freight_app/core/widgets/app_searchbar.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../shared/providers/records_provider.dart';
import '../widgets/record_list_item.dart';
import '../widgets/records_filter_bar.dart';
import 'add_record_screen.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Records')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: AppSearchBar(
              hintText: 'Search by truck or driver name...',
              onChanged: context.read<RecordsProvider>().setSearch,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 0, 0),
            child: RecordsFilterBar(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Consumer<RecordsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const AppLoadingIndicator();

                final records = provider.filteredRecords;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(
                        '${records.length} record${records.length == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: records.isEmpty
                          ? const AppEmptyState(
                              icon: Icons.local_shipping_outlined,
                              title: 'No records found',
                              subtitle:
                                  'Try changing filters or add a new record',
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 100),
                              itemCount: records.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  RecordListItem(record: records[i]),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddRecordScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
