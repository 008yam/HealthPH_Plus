import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'data_collection_page.dart';

import '../models/mobile_survey.dart';
import '../services/api_config.dart';
import '../services/healthph_api_services.dart';
import '../services/sentiment_survey_service.dart';
import 'sentiment_pulse_page.dart';
import '../widgets/coach_mark.dart';
import '../login_page.dart';
import '../data/app_taxonomy.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/floating_navbar.dart';
import 'language_selection_page.dart';
import '../services/app_settings_store.dart';

class SettingsPage extends StatefulWidget {
  final int selectedNavIndex;

  const SettingsPage({super.key, this.selectedNavIndex = 2});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final profileKey = GlobalKey();
  final selfReportKey = GlobalKey();
  final surveyKey = GlobalKey();
  final languageKey = GlobalKey();

  void _logout() {
    ProfileStore.instance.clearProfile();

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
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: HealthPhVisualMode.values.map((mode) {
                final selected = AppSettingsStore.instance.visualMode == mode;

                return _ThemePreviewTile(
                  mode: mode,
                  selected: selected,
                  onTap: () async {
                    await AppSettingsStore.instance.setVisualMode(mode);
                    if (sheetContext.mounted) Navigator.pop(sheetContext);
                  },
                );
              }).toList(),
            ),
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
      const SnackBar(
        content: Text("Please sign in with a registered account first."),
      ),
    );
    return;
  }

  final result = await showDialog<
      ({String pin, String currentPassword})>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _SetPinDialog(),
  );

  if (result == null || !mounted) return;

  try {
    await HealthPhApiService(
      baseUrl: ApiConfig.baseUrl,
    ).setMobileUserPin(
      userId: userId,
      pin: result.pin,
      currentPassword: result.currentPassword,
    );

    await AppSettingsStore.instance.markPinConfigured();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Your PIN was saved successfully.")),
    );
  } catch (error) {
    debugPrint("Unable to save PIN: $error");

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Unable to save PIN. Check your password and connection.",
        ),
      ),
    );
  }
}

Future<void> _replayCoachMarks() async {
  await CoachMark.resetAllDiscoveries();

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Coach marks will replay when you revisit pages.")),
  );
}

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoachMark.showOnce(
        context,
        discoveryKey: "settings_profile_v3",
        steps: [
          CoachMarkStep(
            targetKey: profileKey,
            title: "Profile",
            description:
                "This section shows the details saved from registration.",
            icon: Icons.person_outline,
            color: AppTheme.primary,
          ),
          CoachMarkStep(
            targetKey: surveyKey,
            title: "Mobile Surveys",
            description: "Answer active surveys published for mobile users.",
            icon: Icons.poll_outlined,
            color: AppTheme.info,
          ),
          CoachMarkStep(
            targetKey: selfReportKey,
            title: "Self Reporting",
            description:
                "Use this to report symptoms and support respiratory surveillance.",
            icon: Icons.assignment_add,
            color: AppTheme.warning,
          ),
          CoachMarkStep(
            targetKey: languageKey,
            title: "Language Selection",
            description:
                "Choose the language that is most comfortable for you.",
            icon: Icons.language,
            color: AppTheme.info,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile;
    final isTablet = Responsive.isTablet(context);
    final maxContentWidth = isTablet ? 620.0 : Responsive.formMaxWidth(context);
    final isProfileTab = widget.selectedNavIndex == 3;
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
              96,
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
                      isProfileTab ? "Profile" : "Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appSettings.visualMode.onBackground,
                        fontSize: isTablet ? 34 : 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isProfileTab
                          ? "Account, reports, surveys, and sign-in options"
                          : "Display, language, and guide preferences",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: appSettings.visualMode.onBackgroundMuted,
                        fontSize: isTablet ? 17 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (isProfileTab) ...[
                      KeyedSubtree(
                        key: profileKey,
                        child: _ProfileCard(profile: profile, isTablet: isTablet),
                      ),
                      const SizedBox(height: 18),
                      KeyedSubtree(
                        key: selfReportKey,
                        child: _SelfReportButton(isTablet: isTablet),
                      ),
                      const SizedBox(height: 12),
                      KeyedSubtree(
                        key: surveyKey,
                        child: _SurveyButton(isTablet: isTablet),
                      ),
                      const SizedBox(height: 18),
                      _AuthenticationSection(
                        isTablet: isTablet,
                        settings: appSettings,
                        onSetPin: _setPin,
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.logout_rounded,
                        title: "Logout",
                        subtitle: "Clear this session and return to login",
                        isTablet: isTablet,
                        accentColor: AppTheme.highRisk,
                        surfaceColor: const Color(0xFFFFF1F2),
                        onTap: _logout,
                      ),
                    ] else ...[
                      _SettingsSectionTitle(title: "Display", isTablet: isTablet),
                      _SettingsTile(
                        icon: Icons.palette_outlined,
                        title: "Appearance",
                        subtitle: "Current theme: ${appSettings.visualMode.label}",
                        isTablet: isTablet,
                        accentColor: appSettings.visualMode.accentColor,
                        borderColor: appSettings.visualMode.accentColor.withValues(alpha: 0.45),
                        onTap: _showAppearancePicker,
                      ),
                      const SizedBox(height: 12),
                      _SettingsTile(
                        icon: Icons.tips_and_updates_outlined,
                        title: "Replay Coach Marks",
                        subtitle: "Show guide highlights again",
                        isTablet: isTablet,
                        accentColor: AppTheme.info,
                        borderColor: AppTheme.warning.withValues(alpha: 0.45),
                        onTap: _replayCoachMarks,
                      ),
                      const SizedBox(height: 18),
                      _SettingsSectionTitle(title: "Language", isTablet: isTablet),
                      KeyedSubtree(
                        key: languageKey,
                        child: _SettingsTile(
                          icon: Icons.language,
                          title: "Language Selection",
                          subtitle: "Choose English, Filipino, Cebuano, Ilocano, or Hiligaynon",
                          isTablet: isTablet,
                          borderColor: AppTheme.info.withValues(alpha: 0.45),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LanguageSelectionPage(returnToSettings: true),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: widget.selectedNavIndex,
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isTablet;

  const _ProfileCard({required this.profile, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = profile != null;
    final isGuest =
        !isLoggedIn ||
        AppTaxonomy.isGuestRole(profile!.roleId) ||
        profile!.email == AppTaxonomy.guestEmail;

    final name = isGuest ? "Guest User" : profile!.fullName;
    final email = isGuest ? "Tap to create your profile" : profile!.email;
    final role = isGuest ? "Guest Access" : profile!.role;
    final location = !isGuest && profile!.hasAddress
        ? profile!.locationLabel
        : "Complete your address during registration";

    final accent = isGuest ? Colors.grey.shade600 : AppTheme.primary;
    final surfaceStart = isGuest
        ? const Color(0xFFF0F1F3)
        : const Color(0xFFEFF3FF);
    final surfaceEnd = isGuest ? const Color(0xFFE4E6EA) : Colors.white;
    final avatarColor = isGuest
        ? Colors.grey.shade200
        : AppTheme.primary.withValues(alpha: 0.13);
    final borderColor = isGuest ? Colors.grey.shade300 : AppTheme.primary;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isGuest
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(startAsRegistering: true),
                    ),
                  );
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            padding: EdgeInsets.fromLTRB(
              isTablet ? 28 : 20,
              isTablet ? 28 : 22,
              isTablet ? 28 : 20,
              isTablet ? 26 : 22,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isGuest
                    ? [surfaceStart, surfaceEnd]
                    : [
                        Colors.white,
                        const Color(0xFFEFF4FF),
                        const Color(0xFFFFF7DC),
                      ],
                stops: isGuest ? null : const [0, 0.66, 1.0],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: borderColor.withValues(alpha: isGuest ? 0.35 : 0.28),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isGuest ? 0.08 : 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: isGuest
                          ? Colors.grey.shade200
                          : AppTheme.success.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isGuest ? "Register" : "Active",
                      style: TextStyle(
                        color: isGuest
                            ? Colors.grey.shade700
                            : AppTheme.success,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _MindfulGooeyAccentBar(
                  accent: accent,
                  isGuest: isGuest,
                  isTablet: isTablet,
                ),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.88, end: 1),
                  duration: const Duration(milliseconds: 480),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isTablet ? 112 : 94,
                    height: isTablet ? 112 : 94,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarColor,
                      border: Border.all(
                        color: accent.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isGuest
                          ? Icons.person_outline
                          : Icons.verified_user_outlined,
                      color: accent,
                      size: isTablet ? 56 : 46,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isGuest ? Colors.grey.shade700 : AppTheme.text,
                    fontSize: isTablet ? 32 : 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: accent,
                      size: isTablet ? 24 : 21,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        location,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isGuest
                              ? Colors.grey.shade600
                              : AppTheme.mutedText,
                          fontSize: isTablet ? 17 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _ProfileInfoChip(
                      icon: Icons.badge_outlined,
                      label: role,
                      isGuest: isGuest,
                    ),
                    _ProfileInfoChip(
                      icon: Icons.email_outlined,
                      label: email,
                      isGuest: isGuest,
                    ),
                    _ProfileInfoChip(
                      icon: Icons.home_work_outlined,
                      label: isGuest ? "No saved address" : profile!.barangay,
                      isGuest: isGuest,
                    ),
                    _ProfileInfoChip(
                      icon: Icons.location_city_outlined,
                      label: isGuest ? "No city" : profile!.city,
                      isGuest: isGuest,
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

class _ProfileInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isGuest;

  const _ProfileInfoChip({
    required this.icon,
    required this.label,
    required this.isGuest,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: isGuest ? Colors.grey.shade100 : const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isGuest ? Colors.grey.shade300 : AppTheme.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isGuest ? Colors.grey.shade500 : AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isGuest ? Colors.grey.shade600 : AppTheme.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MindfulGooeyAccentBar extends StatefulWidget {
  final Color accent;
  final bool isGuest;
  final bool isTablet;

  const _MindfulGooeyAccentBar({
    required this.accent,
    required this.isGuest,
    required this.isTablet,
  });

  @override
  State<_MindfulGooeyAccentBar> createState() => _MindfulGooeyAccentBarState();
}

class _MindfulGooeyAccentBarState extends State<_MindfulGooeyAccentBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.isGuest
        ? [Colors.grey.shade300, Colors.grey.shade100, Colors.grey.shade300]
        : [
            widget.accent.withValues(alpha: 0.22),
            AppTheme.info.withValues(alpha: 0.42),
            AppTheme.warning.withValues(alpha: 0.34),
            widget.accent.withValues(alpha: 0.22),
          ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: double.infinity,
        height: widget.isTablet ? 9 : 7,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final shift = -1.0 + (controller.value * 2.0);

            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + shift, 0),
                  end: Alignment(1.0 + shift, 0),
                  colors: colors,
                ),
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _SelfReportButton extends StatelessWidget {
  final bool isTablet;

  const _SelfReportButton({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF4D6),
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataCollectionPage()),
          );
        },
        child: Container(
          height: isTablet ? 155 : 125,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.warning, width: 1.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: isTablet ? 68 : 56,
                height: isTablet ? 68 : 56,
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Icon(
                  Icons.assignment_add,
                  color: AppTheme.warning,
                  size: isTablet ? 36 : 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  "Self-Reporting",
                  style: TextStyle(
                    color: AppTheme.text,
                    fontSize: isTablet ? 28 : 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppTheme.warning,
                size: isTablet ? 32 : 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveyButton extends StatefulWidget {
  final bool isTablet;

  const _SurveyButton({required this.isTablet});

  @override
  State<_SurveyButton> createState() => _SurveyButtonState();
}

class _SurveyButtonState extends State<_SurveyButton> {
  late Future<List<MobileSurvey>> surveyFuture;

  final surveyService = SentimentSurveyService(baseUrl: ApiConfig.baseUrl);

  @override
  void initState() {
    super.initState();
    surveyFuture = surveyService.fetchPublicSurveys();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MobileSurvey>>(
      future: surveyFuture,
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        final hasSurvey = count > 0;

        return Material(
          color: hasSurvey ? const Color(0xFFEAF6FF) : const Color(0xFFF4F7FB),
          borderRadius: BorderRadius.circular(16),
          elevation: hasSurvey ? 5 : 2,
          shadowColor: Colors.black26,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SentimentPulsePage(initialTabIndex: 3),
                ),
              );
            },
            child: Container(
              height: widget.isTablet ? 155 : 125,
              padding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 28 : 20,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasSurvey ? AppTheme.info : AppTheme.border,
                  width: 1.4,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: widget.isTablet ? 68 : 56,
                        height: widget.isTablet ? 68 : 56,
                        decoration: BoxDecoration(
                          color: AppTheme.info.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          Icons.poll_outlined,
                          color: AppTheme.info,
                          size: widget.isTablet ? 36 : 30,
                        ),
                      ),
                      if (hasSurvey)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.warning,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mobile Surveys",
                          style: TextStyle(
                            color: AppTheme.text,
                            fontSize: widget.isTablet ? 28 : 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hasSurvey
                              ? "$count survey ready to answer"
                              : "Check available surveys",
                          style: TextStyle(
                            color: hasSurvey
                                ? AppTheme.info
                                : AppTheme.mutedText,
                            fontSize: widget.isTablet ? 15 : 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: hasSurvey ? AppTheme.info : AppTheme.mutedText,
                    size: widget.isTablet ? 32 : 28,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSectionTitle extends StatelessWidget {
  final String title;
  final bool isTablet;

  const _SettingsSectionTitle({required this.title, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.9),
          fontSize: isTablet ? 18 : 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SetPinDialog extends StatefulWidget {
  const _SetPinDialog();

  @override
  State<_SetPinDialog> createState() => _SetPinDialogState();
}

class _SetPinDialogState extends State<_SetPinDialog> {
  final pinControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  final pinFocusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  final passwordController = TextEditingController();

  String? errorMessage;

  String get enteredPin {
    return pinControllers.map((controller) => controller.text).join();
  }

  void handleDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < pinFocusNodes.length - 1) {
        pinFocusNodes[index + 1].requestFocus();
      } else {
        pinFocusNodes[index].unfocus();
      }
    } else if (index > 0) {
      pinFocusNodes[index - 1].requestFocus();
    }
  }

  void submit() {
    final pin = enteredPin;
    final currentPassword = passwordController.text;

    if (!RegExp(r"^\d{6}$").hasMatch(pin)) {
      setState(() {
        errorMessage = "Enter all six PIN digits.";
      });
      return;
    }

    if (currentPassword.isEmpty) {
      setState(() {
        errorMessage = "Enter your current account password.";
      });
      return;
    }

    Navigator.pop(
      context,
      (
        pin: pin,
        currentPassword: currentPassword,
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in pinControllers) {
      controller.dispose();
    }

    for (final focusNode in pinFocusNodes) {
      focusNode.dispose();
    }

    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Set six-digit PIN"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Enter a six-digit numeric PIN. Each digit uses a separate box.",
            ),
            const SizedBox(height: 18),
            Row(
              children: List.generate(6, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == 5 ? 0 : 6,
                    ),
                    child: TextField(
                      controller: pinControllers[index],
                      focusNode: pinFocusNodes[index],
                      autofocus: index == 0,
                      obscureText: true,
                      obscuringCharacter: "•",
                      keyboardType: TextInputType.number,
                      textInputAction: index == 5
                          ? TextInputAction.done
                          : TextInputAction.next,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onTap: () {
                        final controller = pinControllers[index];

                        controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: controller.text.length,
                        );
                      },
                      onChanged: (value) {
                        handleDigitChanged(index, value);
                      },
                      onSubmitted: (_) {
                        if (index == 5) submit();
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Current password",
                prefixIcon: Icon(Icons.lock_outline),
              ),
              onSubmitted: (_) => submit(),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: AppTheme.highRisk,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: submit,
          child: const Text("Save PIN"),
        ),
      ],
    );
  }
}

class _AuthenticationSection extends StatelessWidget {
  final bool isTablet;
  final AppSettingsStore settings;
  final VoidCallback onSetPin;

  const _AuthenticationSection({
    required this.isTablet,
    required this.settings,
    required this.onSetPin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsSectionTitle(title: "Authentications", isTablet: isTablet),
        _SettingsTile(
        icon: Icons.pin_outlined,
        title: "PIN Login",
        subtitle: !settings.hasPin
            ? "Set PIN first"
            : settings.pinLoginEnabled
                ? "Enabled"
                : "Disabled",
        isTablet: isTablet,
        onTap: () {
          if (!settings.hasPin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "You need to set a six-digit PIN before enabling PIN login.",
                ),
              ),
            );

            onSetPin();
            return;
          }

          AppSettingsStore.instance.setPinLoginEnabled(
            !settings.pinLoginEnabled,
          );
        },
      ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.edit_outlined,
          title: "Set PIN",
          subtitle: settings.hasPin ? "Update PIN" : "Open",
          isTablet: isTablet,
          onTap: onSetPin,
        ),
        const SizedBox(height: 12),
        _SettingsTile(
          icon: Icons.fingerprint,
          title: "Fingerprint Login",
          subtitle: settings.fingerprintLoginEnabled ? "Enabled" : "Available",
          isTablet: isTablet,
          onTap: () {
            AppSettingsStore.instance.setFingerprintLoginEnabled(
              !settings.fingerprintLoginEnabled,
            );
          },
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isTablet;
  final Color borderColor;
  final Color accentColor;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    this.borderColor = AppTheme.border,
    this.accentColor = AppTheme.primary,
    this.surfaceColor = const Color(0xFFF8FAFF),
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
                      title,
                      style: TextStyle(
                        color: AppTheme.text,
                        fontSize: isTablet ? 17 : 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: isTablet ? 16 : 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewTile extends StatelessWidget {
  final HealthPhVisualMode mode;
  final bool selected;
  final VoidCallback onTap;

  const _ThemePreviewTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? mode.accentColor : AppTheme.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            mode.backgroundAsset,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          mode.label,
          style: const TextStyle(
            color: AppTheme.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          mode.description,
          style: const TextStyle(color: AppTheme.mutedText),
        ),
        trailing: selected
            ? Icon(Icons.check_circle, color: mode.accentColor)
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}
