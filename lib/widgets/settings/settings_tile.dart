import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isTablet;
  final Color borderColor;
  final Color accentColor;
  final Color surfaceColor;
  final Color? subtitleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    this.borderColor = AppTheme.border,
    this.accentColor = AppTheme.primary,
    this.surfaceColor = AppTheme.surface,
    this.subtitleColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 20 : 14,
            vertical: isTablet ? 16 : 12,
          ),
          child: Row(
            children: [
              Icon(icon, color: accentColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr(title),
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: isTablet ? 17 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr(subtitle),
                      style: TextStyle(
                        color: subtitleColor ?? AppTheme.mutedText,
                        fontSize: isTablet ? 16 : 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  trailing ??
                  const Icon(Icons.chevron_right, color: AppTheme.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
