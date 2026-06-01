import 'package:flutter/material.dart';
import '../widgets/floating_navbar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4C98),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, size: 90, color: Colors.white),

                SizedBox(height: 20),

                Text(
                  "Settings Page",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text("Coming Soon", style: TextStyle(color: Colors.white70)),
                SizedBox(height: 100),
                FloatingNavBar(selectedIndex: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
