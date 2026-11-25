import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import 'home_surface.dart';
import 'quick_action_tile.dart';

class HomeContributionActions extends StatelessWidget {
  final VoidCallback onDataCollection;
  final VoidCallback onSentimentPulse;

  const HomeContributionActions({
    super.key,
    required this.onDataCollection,
    required this.onSentimentPulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: homeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Your Health Contribution'),
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(
              'Report symptoms, review contribution, or answer surveys',
            ),
            style: const TextStyle(
              color: AppTheme.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          QuickActionTile(
            title: 'Data Collection and Self-Report',
            subtitle: 'Submit symptoms and health information',
            icon: Icons.assignment_add,
            iconColor: AppTheme.warning,
            onTap: onDataCollection,
          ),
          QuickActionTile(
            title: 'Sentiment Pulse and Mobile Survey',
            subtitle: 'View surveys available for mobile users',
            icon: Icons.poll_outlined,
            iconColor: AppTheme.info,
            onTap: onSentimentPulse,
          ),
        ],
      ),
    );
  }
}