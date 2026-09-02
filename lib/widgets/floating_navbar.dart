import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../pages/map_page.dart';
import '../pages/settings_page.dart';
import '../data/app_taxonomy.dart';
import '../services/profile_store.dart';
import 'package:healthphplus/main_page.dart';
import 'package:healthphplus/login_page.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;

  const FloatingNavBar({super.key, required this.selectedIndex});

  static const Duration _pillDuration = Duration(milliseconds: 380);
  static const Duration _tapPreviewDelay = Duration(milliseconds: 140);
  static const Duration _pageTransitionDuration = Duration(milliseconds: 320);

  static const double _iconPopScale = 1.28;
  static const double _iconLift = -5;

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    if (index == 3) {
      final profile = ProfileStore.instance.profile;
      final isGuest =
          profile == null ||
          AppTaxonomy.isGuestRole(profile.roleId) ||
          profile.email == AppTaxonomy.guestEmail;

           final page = isGuest
          ? const LoginPage(startAsRegistering: true)
          : const SettingsPage(selectedNavIndex: 3);

      _pushWithTransition(context, page, index);
      return;
    }

    Widget page;

    switch (index) {
      case 0:
        page = const MapPage();
        break;

      case 1:
        page = const MainPage();
        break;

      case 2:
        page = const SettingsPage(selectedNavIndex: 2);
        break;

      default:
        page = const MainPage();
    }

    _pushWithTransition(context, page, index);
  }
    void _pushWithTransition(BuildContext context, Widget page, int nextIndex) {
    final slideFromRight = nextIndex > selectedIndex;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: _pageTransitionDuration,
        reverseTransitionDuration: _pageTransitionDuration,
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, animation, _, child) {
          final offsetAnimation = Tween<Offset>(
            begin: Offset(slideFromRight ? 0.12 : -0.12, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(context, index: 0, icon: Icons.map, label: "Map"),
              _navItem(context, index: 1, icon: Icons.home, label: "Home"),
              _navItem(
                context,
                index: 2,
                icon: Icons.settings,
                label: "Settings",
              ),
              _navItem(
                context,
                index: 3,
                icon: Icons.person_outline,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    return _AnimatedNavItem(
      icon: icon,
      label: label,
      isSelected: isSelected,
      showLabel: isSelected && !Responsive.isSmallPhone(context),
      onTap: () => _navigate(context, index),
    );
  }
}

class _FlipNavIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final Color color;

  const _FlipNavIcon({
    required this.icon,
    required this.isSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey("${icon.codePoint}-$isSelected"),
      tween: Tween<double>(
        begin: 0,
        end: isSelected ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      child: Icon(icon, color: color),
      builder: (context, value, child) {
        final rotation = isSelected ? value * math.pi * 2: 0.0;
        final pop = math.sin(value * math.pi);
        final scale = isSelected
            ? 1.0 + (pop * (FloatingNavBar._iconPopScale - 1.0))
            : 1.0;
        final lift = isSelected ? pop * FloatingNavBar._iconLift : 0.0;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(rotation),
              child: Transform.translate(
                offset: Offset(0, lift),
                child: Transform.scale(
                  scale: scale,
                  child: child,
                ),
              ),
        );
      },
    );
  }
}

class _AnimatedNavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> {
  bool isPressed = false;

  Future<void> _handleTap() async {
    setState(() => isPressed = true);
    await Future.delayed(FloatingNavBar._tapPreviewDelay);

    if(!mounted) return;

    setState(() => isPressed = false);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedScale(
        scale: isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedContainer(
          duration: FloatingNavBar._pillDuration,
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.24),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                ]
                : null,
          ),
          child: Row (
            children: [
              _FlipNavIcon(
                icon: widget.icon,
                isSelected: widget.isSelected || isPressed,
                color: widget.isSelected ? Colors.white : Colors.grey.shade600,
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                   ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}