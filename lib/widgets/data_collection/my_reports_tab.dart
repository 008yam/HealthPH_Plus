import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../pages/self_report_history_page.dart';
import '../../services/profile_store.dart';
import '../../services/self_report_export_service.dart';
import '../../services/self_report_store.dart';
import '../../theme/app_theme.dart';

class MyReportsTab extends StatelessWidget {
  const MyReportsTab({super.key});

  bool get _canExportReports {
    final roleId = ProfileStore.instance.profile?.roleId ?? '';

    return roleId == 'field_health_worker' || roleId == 'lgu_doh_user';
  }

  Future<void> _exportReports(
    BuildContext context,
    List<SelfReport> reports,
  ) async {
    if (reports.isEmpty) return;

    try {
      final shared = await SelfReportExportService.instance.shareCsv(
        context: context,
        reports: reports,
      );

      if (!context.mounted) return;

      if (shared) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('Self-reports CSV is ready to share.')),
          ),
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('Unable to export self-reports CSV.')),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_canExportReports)
          AnimatedBuilder(
            animation: SelfReportStore.instance,
            builder: (context, _) {
              final localReports = SelfReportStore.instance.reports;

              return Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: context.tr('Export CSV'),
                  onPressed: localReports.isEmpty
                      ? null
                      : () => _exportReports(context, localReports),
                  icon: const Icon(Icons.ios_share),
                  color: AppTheme.primary,
                ),
              );
            },
          ),
        const Expanded(child: SelfReportHistoryPage(embedded: true)),
      ],
    );
  }
}
