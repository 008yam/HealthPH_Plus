import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';
import 'home_surface.dart';
import 'quick_action_tile.dart';

class HomeQuickActions extends StatelessWidget {
  final VoidCallback onDiseaseWatch;
  final VoidCallback onHealthLiteracy;

  const HomeQuickActions({
    super.key,
    required this.onDiseaseWatch,
    required this.onHealthLiteracy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: homeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Quick Actions ⓘ'),
            style: const TextStyle(
              color: AppTheme.text,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          QuickActionTile(
            title: 'Disease Watch',
            subtitle: 'Track outbreaks and alerts',
            icon: Icons.coronavirus,
            iconColor: Colors.redAccent,
            onTap: onDiseaseWatch,
          ),
          QuickActionTile(
            title: 'Health Literacy',
            subtitle: 'Public attitude insights',
            icon: Icons.article_outlined,
            iconColor: Colors.green,
            onTap: onHealthLiteracy,
          ),
        ],
      ),
    );
  }
}
