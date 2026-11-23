import 'package:flutter/material.dart';

import '../../data/app_taxonomy.dart';
import '../../localization/app_translations.dart';
import '../../services/profile_store.dart';
import '../../theme/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile? profile;
  final bool isTablet;
  final VoidCallback onRegister;

  const ProfileCard({
    super.key,
    required this.profile,
    required this.isTablet,
    required this.onRegister,
  });
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = profile != null;
    final isGuest =
        !isLoggedIn ||
        AppTaxonomy.isGuestRole(profile!.roleId) ||
        profile!.email == AppTaxonomy.guestEmail;

    final name = isGuest ? context.tr("Guest User") : profile!.fullName;
    final email = isGuest
        ? context.tr("Tap to create your profile")
        : profile!.email;
    final role = context.tr(isGuest ? "Guest Access" : profile!.role);
    final location = !isGuest && profile!.hasAddress
        ? profile!.locationLabel
        : context.tr("Complete your address during registration");

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
          onTap: isGuest ? onRegister : null,
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
                      isGuest ? context.tr("Register") : context.tr("Active"),
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
                      label: isGuest
                          ? context.tr("No saved address")
                          : profile!.barangay,
                      isGuest: isGuest,
                    ),
                    _ProfileInfoChip(
                      icon: Icons.location_city_outlined,
                      label: isGuest ? context.tr("No city") : profile!.city,
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
