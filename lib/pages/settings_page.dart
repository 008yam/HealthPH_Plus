import 'package:flutter/material.dart';
import 'data_collection_page.dart';

import '../models/mobile_survey.dart';
import '../services/api_config.dart';
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

    return Scaffold(
      extendBody: true,
      backgroundColor: AppTheme.pageBlue,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.pageBlue,
          image: DecorationImage(
            image: AssetImage('assets/images/Backdrop1.png'),
            fit: BoxFit.cover,
            opacity: 0.24,
          ),
        ),
        child: SafeArea(
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
                    Center(
                      child: Image.asset(
                        'assets/images/healthphplusbarlogo.png',
                        height: isTablet ? 64 : 46,
                      ),
                    ),
                    SizedBox(height: isTablet ? 28 : 20),
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
                    KeyedSubtree(
                      key: languageKey,
                      child: _SettingsTile(
                        icon: Icons.language,
                        title: "Language Selection",
                        subtitle:
                            "Choose English, Filipino, Cebuano, Ilocano, or Hiligaynon",
                        isTablet: isTablet,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LanguageSelectionPage(),
                            ),
                          );
                        },
                      ),
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
                  ],
                ),
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isTablet;
  final Color accentColor;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    this.accentColor = AppTheme.primary,
    this.surfaceColor = const Color(0xFFF8FAFF),
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surfaceColor,
      borderRadius: BorderRadius.circular(8),
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
