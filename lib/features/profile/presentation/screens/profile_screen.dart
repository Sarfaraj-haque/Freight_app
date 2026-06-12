import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/export_utils.dart';
import '../../../../core/utils/import_utils.dart';
import '../../../../core/widgets/action_tile.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/records_provider.dart';
import '../../../../shared/models/freight_record.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_stats_row.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Consumer<RecordsProvider>(
          builder: (context, provider, _) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const ProfileAvatar(),
                ),
                const SizedBox(height: 20),
                ProfileStatsRow(
                  total: provider.totalTrips,
                  pending: provider.pendingCount,
                  completed: provider.totalTrips - provider.pendingCount,
                ),
                const SizedBox(height: 24),
                ActionTile(
                  icon: Icons.upload_file_outlined,
                  title: 'Bulk Import (Excel / CSV)',
                  subtitle: 'Upload .xlsx, .xls or .csv with multiple records',
                  iconColor: AppColors.primary,
                  onTap: () => _handleBulkImport(context),
                ),
                const SizedBox(height: 10),
                ActionTile(
                  icon: Icons.file_download_outlined,
                  title: 'Download Excel Template',
                  subtitle: 'Get a ready-made .xlsx file to fill in',
                  iconColor: AppColors.primary,
                  onTap: () => _showComingSoon(context),
                ),
                const SizedBox(height: 10),
                ActionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Import Format Guide',
                  subtitle: 'View accepted columns and date formats',
                  iconColor: AppColors.textSecondary,
                  iconBackgroundColor: AppColors.surfaceVariant,
                  onTap: () => _showFormatGuide(context),
                ),
                const SizedBox(height: 10),
                ActionTile(
                  icon: Icons.table_chart_outlined,
                  title: 'Export Records (Excel)',
                  subtitle: '${provider.totalTrips} records available',
                  iconColor: AppColors.primary,
                  onTap: () => _handleExport(context, provider.allRecords),
                ),
                const SizedBox(height: 10),
                ActionTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Securely log out of your account',
                  iconColor: AppColors.error,
                  iconBackgroundColor: AppColors.errorLight,
                  titleColor: AppColors.error,
                  onTap: () => _confirmSignOut(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming soon!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showFormatGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Import Format Guide',
                style: AppTextStyles.headlineMedium),
            const SizedBox(height: 8),
            const Text('Ensure your Excel/CSV follows this column order:',
                style: AppTextStyles.bodySmall),
            const SizedBox(height: 16),
            const _FormatRow('DATE', 'YYYY-MM-DD'),
            const _FormatRow('TRUCK NO.', 'MH12AB1234'),
            const _FormatRow('QNT.', 'Quantity (10.4)'),
            const _FormatRow('CHALLAN QNT.', '10.0'),
            const _FormatRow('DISEL', 'Diesel Amount'),
            const _FormatRow('ADV', 'Advance Amount'),
            const _FormatRow('RATE', '285'),
            const _FormatRow('SHORT AMNT', 'Shortage Amount'),
            const _FormatRow('UNLODING', 'Unloading Charges'),
            const _FormatRow('FRIEIGHT', 'Total Freight (Calculated)'),
            const _FormatRow('NAME', 'Driver Name'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
      BuildContext context, List<FreightRecord> records) async {
    if (records.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records to export')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating Excel file...')),
    );

    final path = await ExportUtils.exportToExcel(records);

    if (!context.mounted) return;

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File exported successfully: ${path.split('/').last}'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export cancelled or failed')),
      );
    }
  }

  Future<void> _handleBulkImport(BuildContext context) async {
    final records = await ImportUtils.pickAndParse();
    if (records != null && records.isNotEmpty) {
      if (!context.mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Confirm Import'),
          content: Text('Do you want to import ${records.length} records?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        if (!context.mounted) return;
        await context.read<RecordsProvider>().bulkAddRecords(records);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Successfully imported ${records.length} records')),
        );
      }
    } else if (records != null && records.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid records found in the file')),
      );
    }
  }
}

class _FormatRow extends StatelessWidget {
  const _FormatRow(this.column, this.format);
  final String column;
  final String format;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              child: Text(column,
                  style: AppTextStyles.titleMedium
                      .copyWith(fontFamily: 'monospace'))),
          Text(format,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
