import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class SettingsSectionCard extends StatelessWidget {
  final Widget child;

  const SettingsSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceSoft,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

class SettingsSectionTitle extends StatelessWidget {
  final String title;
  final bool isTablet;

  const SettingsSectionTitle({
    super.key,
    required this.title,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        context.tr(title),
        style: TextStyle(
          color: AppTheme.text,
          fontSize: isTablet ? 18 : 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
