import 'package:flutter/material.dart';
import 'intro_tutorial_page.dart';
import '../theme/app_theme.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String selectedLanguage = "English";

  final List<String> languages = const [
    "English",
    "Filipino",
    "Cebuano",
    "Ilocano",
    "Hiligaynon",
  ];
 
  void _continueToApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const IntroTutorialPage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Backdrop3.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/healthphplusbarlogo.png',
                    height: 52,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "Choose Language",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Select your preferred language for HealthPH+.",
                    style: TextStyle(
                      color: Colors.white70,
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border:Border.all(
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                width: isSelected ? 2 :1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.mutedText,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    language,
                                    style: const TextStyle(
                                      color: AppTheme.text,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
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