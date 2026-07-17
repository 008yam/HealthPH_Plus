import 'package:flutter/material.dart';
import '../pages/map_page.dart';
import '../pages/settings_page.dart';
import 'package:healthphplus/main_page.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;

  const FloatingNavBar({super.key, required this.selectedIndex});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    if (index == 3) {
      Navigator.pushReplacementNamed(context, '/login');
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
        page = const SettingsPage();
        break;

      default:
        page = const MainPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
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

    return GestureDetector(
      onTap: () => _navigate(context, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),

            if (isSelected && !Responsive.isSmallPhone(context)) ...[
              const SizedBox(width: 6),

              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
