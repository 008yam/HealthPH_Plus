import 'package:flutter/material.dart';
import 'data_collection_page.dart';

import '../widgets/coach_mark.dart';

import '../login_page.dart';
import '../services/profile_store.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/floating_navbar.dart';
import 'language_selection_page.dart';

class SettingsPage extends StatefulWidget {
  final int selectedNavIndex;

  const SettingsPage({
    super.key,
    this.selectedNavIndex = 2,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final profileKey = GlobalKey();
  final selfReportKey = GlobalKey();
  final languageKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      CoachMark.showOnce(
        context,
        discoveryKey: "settings_profile_v2",
        steps: [
          CoachMarkStep(
            targetKey: profileKey,
            title: "Profile",
            description: "This section shows the details saved from registration.",
            icon: Icons.person_outline,
            color: AppTheme.primary,
          ),
          CoachMarkStep(
            targetKey: selfReportKey,
            title: "Self Reporting",
            description: "Use this to report symptoms and support respiratory surveillance.",
            icon: Icons.assignment_add,
            color: AppTheme.warning,
          ),
          CoachMarkStep(
            targetKey: languageKey,
            title: "Language Selection",
            description: "Choose the language that is most comfortable for you.",
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
    final isGuest = !isLoggedIn ||
        profile!.email == "guest@healthphplus.local" ||
        profile!.role == "Guest Tester";

    final name = isGuest ? "Guest User" : profile!.fullName;
    final email = isGuest ? "Tap to create your profile" : profile!.email;
    final role = isGuest ? "Guest Access" : profile!.role;
    final location = !isGuest && profile!.hasAddress
        ? profile!.locationLabel
        : "Complete your address during registration";

    final accent = isGuest ? Colors.grey.shade600 : AppTheme.primary;
    final surfaceStart =
        isGuest ? const Color(0xFFF0F1F3) : const Color(0xFFEFF3FF);
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
                colors: [surfaceStart, surfaceEnd],
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
                const SizedBox(height: 6),
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
              Expanded(child: Text(
                "Self-Reporting",
                style: TextStyle(
                  color: AppTheme.text,
                  fontSize: isTablet ?  28 : 23,
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isTablet;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFF),
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
              Icon(icon, color: AppTheme.primary),
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

