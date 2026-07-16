import 'package:flutter/material.dart';
import 'language_selection_page.dart';
import '../widgets/floating_navbar.dart';
import '../theme/app_theme.dart';
import '../services/profile_store.dart';
import '../theme/responsive.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile;
    final isTablet = Responsive.isTablet(context);
    final maxContentWidth = isTablet ? 620.0 : Responsive.formMaxWidth(context);
    return Scaffold(
      backgroundColor: AppTheme.pageBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Backdrop1.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.16),
            ), 
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.pagePadding(context),
                isTablet ? 28 : 18,
                Responsive.pagePadding(context),
                96
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
                          height: isTablet ? 26 : 18,
                        ),
                      ),
                      SizedBox(height: isTablet ? 26 :18),
                      Text(
                        "Settings",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 34 : 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Account, language, and App Reference",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: isTablet ? 16 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: isTablet ?  28 : 20),

                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: AppTheme.cardDecoration,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: isTablet ? 30: 24,
                              backgroundColor: AppTheme.primary.withValues(alpha: 0.12),
                              child: Icon(
                                Icons.person_outline,
                                color: AppTheme.primary,
                                size: isTablet ? 32 : 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.fullName ?? "Profile / Login",
                                    style: TextStyle(
                                      color: AppTheme.text,
                                      fontSize: isTablet ? 18 : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    profile == null
                                        ? "Manage your account and registration details."
                                        : "${profile.email}\n${profile.locationLabel}",
                                    style: TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: isTablet ? 14: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, '/login'),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      ListTile(
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 20 : 14,
                          vertical: isTablet ? 10 : 6,
                        ),
                        leading: const Icon(Icons.language, color: AppTheme.primary),
                        title: Text(
                          "Language",
                          style: TextStyle(
                            fontSize: isTablet ? 17 : 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LanguageSelectionPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),),
              ),
            ))
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 2),
    );
    
  }
}

/*
body: SafeArea(
        child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.formMaxWidth(context),
            ),
            child: Column(
              children: [
                const Icon(Icons.settings, size: 90, color: Colors.white),

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
      ),*/