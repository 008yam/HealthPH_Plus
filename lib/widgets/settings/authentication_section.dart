import 'package:flutter/material.dart';

import '../../localization/app_translations.dart';
import '../../services/app_settings_store.dart';
import 'settings_section.dart';
import 'settings_tile.dart';
import '../app_notice.dart';
import '../../theme/app_theme.dart';

class AuthenticationSection extends StatelessWidget {
  final bool isTablet;
  final AppSettingsStore settings;
  final VoidCallback onSetPin;

  const AuthenticationSection({
    super.key,
    required this.isTablet,
    required this.settings,
    required this.onSetPin,
  });

  Future<void> _setPinLoginEnabled(BuildContext context, bool enabled) async {
    if (!settings.hasPin) {
      onSetPin();
      return;
    }

    await settings.setPinLoginEnabled(enabled);

    if (!context.mounted) return;

    if (enabled) {
      AppNotice.success(context, context.tr('PIN Login enabled.'));
    } else {
      AppNotice.info(context, context.tr('PIN Login disabled.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final pinEnabled = settings.hasPin && settings.pinLoginEnabled;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSectionTitle(
              title: 'Authentication',
              isTablet: isTablet,
            ),
            SettingsTile(
              icon: Icons.pin_outlined,
              title: 'PIN Login',
              subtitle: !settings.hasPin
                  ? 'Set a PIN to enable this feature'
                  : pinEnabled
                      ? 'On'
                      : 'Off',
              subtitleColor:
                  pinEnabled ? AppTheme.success : AppTheme.highRisk,
              accentColor:
                  pinEnabled ? AppTheme.success : AppTheme.highRisk,
              borderColor: pinEnabled
                  ? AppTheme.success.withValues(alpha: 0.45)
                  : AppTheme.highRisk.withValues(alpha: 0.35),
              isTablet: isTablet,
              trailing: Transform.scale(
                scale: 0.82,
                child: Switch.adaptive(
                  value: pinEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppTheme.success,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: AppTheme.highRisk,
                  onChanged: (enabled) {
                    _setPinLoginEnabled(context, enabled);
                  },
                ),
              ),
              onTap: () {
                _setPinLoginEnabled(context, !pinEnabled);
              },
            ),
            const SizedBox(height: 12),
            SettingsTile(
              icon: settings.hasPin
                  ? Icons.edit_outlined
                  : Icons.add_moderator_outlined,
              title: settings.hasPin ? 'Update PIN' : 'Set PIN',
              subtitle: settings.hasPin
                  ? 'Change your current login PIN'
                  : 'Create a PIN for faster login',
              isTablet: isTablet,
              accentColor: AppTheme.primary,
              borderColor: AppTheme.primary.withValues(alpha: 0.35),
              onTap: onSetPin,
            ),
          ],
        );
      },
    );
  }
}