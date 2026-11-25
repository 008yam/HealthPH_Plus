import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String location;
  final String percent;
  final String? metricLabel;
  final double progress;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.location,
    required this.percent,
    this.metricLabel,
    required this.progress,
    this.onTap,
  });

  String get _percentLabel {
    final metric = metricLabel?.trim();

    if (metric != null && metric.isNotEmpty) {
      return metric;
    }

    final value = percent.trim();

    if (value.isEmpty) {
      return '${(progress * 100).round()}%';
    }

    return value;
  }

  Color get _severityColor {
    final cleaned = percent.replaceAll('%', '').trim();
    final value = double.tryParse(cleaned) ?? (progress * 100);

    if (value >= 20) {
      return AppTheme.warning;
    }

    if (value >= 10) {
      return AppTheme.pageBlue;
    }

    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor;
    final progressValue = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: severityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _percentLabel,
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(height: 8, color: AppTheme.progressTrack),
                      FractionallySizedBox(
                        widthFactor: progressValue,
                        child: Container(height: 8, color: severityColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 15,
                      color: severityColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('Severity level'),
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      context.tr('View Details'),
                      style: const TextStyle(
                        color: AppTheme.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
