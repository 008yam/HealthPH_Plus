import 'package:flutter/material.dart';
import 'intro_tutorial_page.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/app_taxonomy.dart';
import '../services/api_config.dart';
import '../services/healthph_api_services.dart';
import '../services/profile_store.dart';
import '../services/app_settings_store.dart';

class LanguageSelectionPage extends StatefulWidget {

final bool returnToSettings;

const LanguageSelectionPage({super.key, this.returnToSettings = false});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String selectedLanguage = "";
  bool isLoadingLanguage = true;

  final List<String> languages = const [
    "English",
    "Filipino",
    "Cebuano",
    "Ilocano",
    "Hiligaynon",
  ];

  @override
void initState() {
  super.initState();
  _loadSelectedLanguage();
}

Future<void> _loadSelectedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final profileLanguage = ProfileStore.instance.profile?.language;
  final savedLanguage = prefs.getString("healthph_selected_language");

  String resolvedLanguage = "English";

  if (profileLanguage != null && languages.contains(profileLanguage)) {
    resolvedLanguage = profileLanguage;
  } else if (savedLanguage != null && languages.contains(savedLanguage)) {
    resolvedLanguage = savedLanguage;
  }

  if (!mounted) return;

  setState(() {
    selectedLanguage = resolvedLanguage;
    isLoadingLanguage = false;
  });
}
 
  Future<void> _continueToApp() async {
  final prefs = await SharedPreferences.getInstance();
  final profile = ProfileStore.instance.profile;
  final isRegistered = profile != null &&
      profile.id != null &&
      profile.id!.isNotEmpty &&
      profile.email != AppTaxonomy.guestEmail &&
      !AppTaxonomy.isGuestRole(profile.roleId);

  if (isRegistered) {
    final api = HealthPhApiService(baseUrl: ApiConfig.baseUrl);
    final updatedProfile = await api.updatedMobileUserLanguage(
      userId: profile.id!,
      language: selectedLanguage,
      );
    ProfileStore.instance.saveProfile(updatedProfile);
  } else {
    ProfileStore.instance.updateLanguage(selectedLanguage);
  }

  await prefs.setString("healthph_selected_language", selectedLanguage);

  if (!mounted) return;

  if (widget.returnToSettings) {
    Navigator.pop(context);
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IntroTutorialPage()),
      );
  }
}

  @override
  Widget build(BuildContext context) {
    final visualMode = AppSettingsStore.instance.visualMode;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.pagePadding(context),
                16,
                Responsive.pagePadding(context),
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 54),
                  Text(
                    "Choose Language",
                    style: TextStyle(
                      color: visualMode.onBackground,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Select your preferred language for HealthPH+.",
                    style: TextStyle(
                      color: visualMode.onBackgroundMuted,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView.separated(
                      itemCount: languages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final language = languages[index];
                        final isSelected =selectedLanguage == language;

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            setState(() {
                              selectedLanguage = language;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEFF3FF) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:Border.all(
                                color: isSelected ? AppTheme.primary : AppTheme.mutedText,
                                width: isSelected ? 2 :1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected ? AppTheme.primary : AppTheme.mutedText,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        language,
                                        style: const TextStyle(
                                          color: AppTheme.text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(height: 4),
                                        const Text(
                                          "This is your selected language",
                                          style: TextStyle(
                                            color: AppTheme.primary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primary,
                                    size: 24,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: Responsive.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed: _continueToApp,
                      child: const Text(
                        "Continue",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}