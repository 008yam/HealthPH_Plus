import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../models/self_report_history_models.dart';
import '../../theme/app_theme.dart';

class ContributionSummary extends StatelessWidget {
  final List<ContributionReport> reports;
  final bool isLocalFallback;

  const ContributionSummary({
    super.key,
    required this.reports,
    required this.isLocalFallback,
  });

  @override
  Widget build(BuildContext context) {
    final latest = reports.isEmpty
        ? context.tr("No reports yet")
        : reports.first.dateLabel;
    final topCondition = context.tr(_topConditionLabel(reports));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.assignment_turned_in_outlined,
                    value: reports.length.toString(),
                    label: isLocalFallback ? "Local reports" : "Mongo reports",
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    icon: Icons.monitor_heart_outlined,
                    value: topCondition,
                    label: "Most common concern",
                    color: AppTheme.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _SummaryMetric(
              icon: Icons.schedule_outlined,
              value: latest,
              label: "Latest contribution",
              color: AppTheme.info,
            ),
          ],
        ),
      ),
    );
  }

  String _topConditionLabel(List<ContributionReport> reports) {
    if (reports.isEmpty) return "None";

    final counts = <String, int>{};
    for (final report in reports) {
      counts.update(report.condition, (value) => value + 1, ifAbsent: () => 1);
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.first.key;
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            context.tr(label),
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
