import 'package:flutter/material.dart';
import '../services/api_config.dart';
import '../services/healthph_api_services.dart';
import '../widgets/coach_mark.dart';
import '../login_page.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/floating_navbar.dart';
import 'language_selection_page.dart';
import '../services/app_settings_store.dart';
import '../services/biometric_auth_service.dart';
import '../localization/app_translations.dart';
import '../widgets/settings/profile_card.dart';
import '../widgets/settings/settings_section.dart';
import '../widgets/settings/set_pin_dialog.dart';
import '../widgets/settings/settings_tile.dart';
import '../widgets/settings/authentication_section.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final profileKey = GlobalKey();
  final appearanceKey = GlobalKey();
  final languageKey = GlobalKey();
  final authenticationKey = GlobalKey();

  Future<void> _logout() async {
    await BiometricAuthService.instance.clearSavedProfile();
    await AppSettingsStore.instance.setFingerprintLoginEnabled(false);
    ProfileStore.instance.clearProfile();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _showAppearancePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final screen = MediaQuery.sizeOf(sheetContext);
        final isLandscapePhone = Responsive.isLandscapePhone(sheetContext);

        final sheetHeight = screen.height * (isLandscapePhone ? 0.86 : 0.72);

        return SizedBox(
          height: sheetHeight,
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 4, 16, isLandscapePhone ? 12 : 20),
            itemCount: HealthPhVisualMode.values.length,
            itemBuilder: (context, index) {
              final mode = HealthPhVisualMode.values[index];
              final selected = AppSettingsStore.instance.visualMode == mode;

              return _ThemePreviewTile(
                mode: mode,
                selected: selected,
                compact: isLandscapePhone,
                onTap: () async {
                  await AppSettingsStore.instance.setVisualMode(mode);

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _setPin() async {
    final profile = ProfileStore.instance.profile;
    final userId = profile?.id;

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr("Please sign in with a registered account first."),
          ),
        ),
      );
      return;
    }

    final result = await showDialog<({String pin, String currentPassword})>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const SetPinDialog(),
    );

    if (result == null || !mounted) return;

    try {
      await HealthPhApiService(baseUrl: ApiConfig.baseUrl).setMobileUserPin(
        userId: userId,
        pin: result.pin,
        currentPassword: result.currentPassword,
        accessToken: profile?.accessToken,
      );

      await AppSettingsStore.instance.markPinConfigured();
      if (profile != null) {
        ProfileStore.instance.saveProfile(
          profile.copyWith(pinConfigured: true),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr("Your PIN was saved successfully."))),
      );
    } catch (error) {
      debugPrint("Unable to save PIN: $error");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              "Unable to save PIN. Check your password and connection.",
            ),
          ),
        ),
      );
    }
  }

  Future<void> _replayCoachMarks() async {
    await CoachMark.resetAllDiscoveries();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr("Coach marks will replay when you revisit pages."),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoachMark.showOnce(
        context,
        discoveryKey: "settings_profile_v4",
        steps: [
          CoachMarkStep(
            targetKey: profileKey,
            title: "Profile",
            description:
                "Review the account details and location saved during registration.",
            icon: Icons.person_outline,
            color: AppTheme.primary,
          ),
          CoachMarkStep(
            targetKey: appearanceKey,
            title: "Appearance",
            description:
                "Choose the background and color mode that is most readable for you.",
            icon: Icons.palette_outlined,
            color: AppTheme.warning,
          ),
          CoachMarkStep(
            targetKey: languageKey,
            title: "Language Selection",
            description:
                "Choose the language that is most comfortable for you.",
            icon: Icons.language_rounded,
            color: AppTheme.info,
          ),
          CoachMarkStep(
            targetKey: authenticationKey,
            title: "Login Security",
            description:
                "Set your account PIN and manage fingerprint login when your device supports it.",
            icon: Icons.security_outlined,
            color: AppTheme.success,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile;
    final isTablet = Responsive.isTablet(context);
    final maxContentWidth = Responsive.contentMaxWidth(context);
    final appSettings = AppSettingsStore.instance;

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            Responsive.pagePadding(context),
            Responsive.pagePadding(context),
            Responsive.pagePadding(context),
            Responsive.bottomNavClearance(context),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isTablet ? 52 : 36),
                  const SizedBox(height: 20),
                  Text(
                    context.tr("Profile"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appSettings.visualMode.onBackground,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr(
                      "Account, preferences, security, and accessibility",
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: appSettings.visualMode.onBackground,
                      fontSize: isTablet ? 17 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 22),
                  KeyedSubtree(
                    key: profileKey,
                    child: ProfileCard(
                      profile: profile,
                      isTablet: isTablet,
                      onRegister: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const LoginPage(startAsRegistering: true),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  // START OF PREFERENCES
                  SettingsSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsSectionTitle(
                          title: "Preferences",
                          isTablet: isTablet,
                        ),

                        KeyedSubtree(
                          key: appearanceKey,
                          child: SettingsTile(
                            icon: Icons.palette_outlined,
                            title: "Appearance",
                            subtitle: context.tr(
                              'Current theme: {theme}',
                              parameters: {
                                'theme': context.tr(
                                  appSettings.visualMode.label,
                                ),
                              },
                            ),
                            isTablet: isTablet,
                            accentColor: appSettings.visualMode.accentColor,
                            borderColor: appSettings.visualMode.accentColor
                                .withValues(alpha: 0.45),
                            onTap: _showAppearancePicker,
                          ),
                        ),

                        const SizedBox(height: 12),

                        KeyedSubtree(
                          key: languageKey,
                          child: SettingsTile(
                            icon: Icons.language_rounded,
                            title: "Language Selection",
                            subtitle:
                                "Choose your preferred application language",
                            isTablet: isTablet,
                            accentColor: AppTheme.info,
                            borderColor: AppTheme.info.withValues(alpha: 0.45),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LanguageSelectionPage(
                                    returnToSettings: true,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        SettingsTile(
                          icon: Icons.tips_and_updates_outlined,
                          title: "Replay Coach Marks",
                          subtitle: "Show your guide highlights again",
                          isTablet: isTablet,
                          onTap: _replayCoachMarks,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  KeyedSubtree(
                    key: authenticationKey,
                    child: SettingsSectionCard(
                      child: AuthenticationSection(
                        isTablet: isTablet,
                        settings: appSettings,
                        onSetPin: _setPin,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SettingsSectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SettingsSectionTitle(
                          title: "Account",
                          isTablet: isTablet,
                        ),
                        SettingsTile(
                          icon: Icons.logout_rounded,
                          title: "Logout",
                          subtitle: "Clear this session and return to login.",
                          isTablet: isTablet,
                          accentColor: AppTheme.highRisk,
                          surfaceColor: const Color(0xFFFFF1F2),
                          onTap: _logout,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 2),
    );
  }
}

class _ThemePreviewTile extends StatelessWidget {
  final HealthPhVisualMode mode;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  const _ThemePreviewTile({
    required this.mode,
    required this.selected,
    this.compact = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final previewSize = compact ? 42.0 : 54.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: EdgeInsets.only(bottom: compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? mode.accentColor : AppTheme.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        dense: compact,
        visualDensity: compact
            ? const VisualDensity(horizontal: -1, vertical: -2)
            : VisualDensity.standard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: compact ? 6 : 8,
        ),
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            mode.backgroundAsset,
            width: previewSize,
            height: previewSize,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          context.tr(mode.label),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.text,
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          context.tr(mode.description),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.mutedText,
            fontSize: compact ? 12 : 14,
          ),
        ),
        trailing: selected
            ? Icon(Icons.check_circle, color: mode.accentColor)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
