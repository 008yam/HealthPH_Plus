import 'package:flutter/material.dart';
import 'language_selection_page.dart';
import '../widgets/floating_navbar.dart';
import '../theme/app_theme.dart';
import '../services/profile_store.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile;
    return Scaffold(
      backgroundColor: AppTheme.pageBlue,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, size: 90, color: Colors.white),

                const SizedBox(height: 20),

                const Text(
                  "Settings Page",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                 const Text(
                  "Settings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold
                  ),
                ),
                 const SizedBox(height: 18),

                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: const Icon(Icons.person_outline, color: AppTheme.primary),
                  title: Text(profile?.fullName ?? "Profile / Login"),
                  subtitle: Text(
                    profile == null
                        ? "Manage your account and registration details."
                        : "${profile.email}\n${profile.locationLabel}"
                  ),
                  isThreeLine: profile != null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, '/login'),
                ),

                const SizedBox(height: 10),

                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  leading: const Icon(Icons.language, color: AppTheme.primary),
                  title: const Text("Language"),
                  subtitle: const Text("Choose English, Filipino, Cebuano, Ilocano, or Hiligaynon"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LanguageSelectionPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 2),
    );
    
  }
}
