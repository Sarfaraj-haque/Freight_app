import 'package:flutter/material.dart';
import 'package:freight_app/core/widgets/app_searchbar.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../shared/models/freight_record.dart';
import '../../../../shared/providers/records_provider.dart';
import '../widgets/grouped_record_list_item.dart';
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
                          : _buildRecordList(context, provider, records),
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

  Widget _buildRecordList(
    BuildContext context,
    RecordsProvider provider,
    List<FreightRecord> records,
  ) {
    final isSearching = provider.searchQuery.isNotEmpty;
    final isGroupFilter = provider.filter == RecordFilter.sortByName ||
        provider.filter == RecordFilter.sortByTruckNo;

    if (isSearching || isGroupFilter) {
      // Determine if we should group by Driver or Truck
      bool groupByDriver = provider.filter == RecordFilter.sortByName;

      if (isSearching && !groupByDriver) {
        final q = provider.searchQuery.toLowerCase();
        // If searching and any record's driver name matches exactly or starts with query,
        // consider grouping by driver for a cleaner result.
        if (records.isNotEmpty &&
            records.any((r) => r.driverName.toLowerCase().contains(q))) {
          groupByDriver = true;
        }
      }

      final Map<String, List<FreightRecord>> grouped = {};
      final List<String> orderedKeys = [];

      for (var r in records) {
        final key = groupByDriver ? r.driverName : r.truckNumber;
        if (!grouped.containsKey(key)) {
          orderedKeys.add(key);
          grouped[key] = [];
        }
        grouped[key]!.add(r);
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: orderedKeys.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final title = orderedKeys[index];
          final groupRecords = grouped[title]!;
          return GroupedRecordListItem(
            title: title,
            records: groupRecords,
            isDriverGroup: groupByDriver,
            onTap: () {
              _showGroupDetails(context, title, groupRecords);
            },
          );
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => RecordListItem(record: records[i]),
    );
  }

  void _showGroupDetails(
      BuildContext context, String truck, List<FreightRecord> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('Records for $truck',
                        style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${records.length}',
                        style: AppTextStyles.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: records.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => RecordListItem(record: records[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
