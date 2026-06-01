import 'package:flutter/material.dart';
import '../pages/map_page.dart';
import '../pages/settings_page.dart';
import 'package:healthphplus/main_page.dart';

class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;

  const FloatingNavBar({super.key, required this.selectedIndex});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

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
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 4),
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
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF31459B) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.grey.shade600),

            if (isSelected) ...[
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
