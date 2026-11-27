import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import '../app_skeleton.dart';

class HistoryNoticeCard extends StatelessWidget {
  final String message;

  const HistoryNoticeCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withValues(alpha: 0.35)),
      ),
      child: Text(
        context.tr(message),
        style: const TextStyle(
          color: AppTheme.text,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class HistoryLoadingCard extends StatelessWidget {
  const HistoryLoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppSkeleton(height: 92, width: double.infinity),
        const SizedBox(height: 14),
        ...List.generate(
          3,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeleton(height: 18, width: 190),
                SizedBox(height: 10),
                AppSkeleton(height: 13, width: double.infinity),
                SizedBox(height: 7),
                AppSkeleton(height: 13, width: 230),
                SizedBox(height: 12),
                Divider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HistoryErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const HistoryErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.highRisk.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: AppTheme.highRisk,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            context.tr(message),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.tr("Try again")),
          ),
        ],
      ),
    );
  }
}

class EmptyContributionCard extends StatelessWidget {
  const EmptyContributionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.assignment_late_outlined,
            color: AppTheme.mutedText,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            context.tr("No self-reports yet"),
            style: TextStyle(
              color: AppTheme.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 5),
          Text(
            context.tr("Submitted self-reports will appear here for review."),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.mutedText, height: 1.35),
          ),
        ],
      ),
    );
  }
}
