import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_page.dart';

class IntroTutorialPage extends StatefulWidget {
  const IntroTutorialPage({super.key});

  @override
  State<IntroTutorialPage> createState() => _IntroTutorialPageState();
}

class _IntroTutorialPageState extends State<IntroTutorialPage> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  static const List<_TutorialItem> tutorials = [
    _TutorialItem(
      icon: Icons.coronavirus,
      title: "Disease Watch",
      description:
          "Monitor outbreak reports, active cases, and disease risk signals across regions.",
    ),
    _TutorialItem(
      icon: Icons.map,
      title: "Disease Map",
      description:
          "View outbreak activity geographically and identify affected areas faster.",
    ),
    _TutorialItem(
      icon: Icons.article_outlined,
      title: "Health Literacy Hub",
      description:
          "Read evidence-based health articles and review fact-checking information.",
    ),
    _TutorialItem(
      icon: Icons.analytics,
      title: "Sentiment Pulse",
      description:
          "Understand public concern, misinformation, and health behavior trends.",
    ),
    _TutorialItem(
      icon: Icons.assignment,
      title: "Data Collection",
      description:
          "Submit and review symptom reports that support public health monitoring.",
    ),
  ];

  bool get isLastPage => currentIndex == tutorials.length - 1;

  void _finishTutorial() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPage()),
      );
  }

  void _nextPage() {
    if (isLastPage) {
      _finishTutorial();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Backdrop1.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/healthphplusbarlogo.png',
                    height: 52,
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 380),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 260,
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: tutorials.length,
                            onPageChanged: (index) {
                              setState(() {
                                currentIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = tutorials[index];

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor:
                                        AppTheme.primary.withValues(alpha: 0.12),
                                    child: Icon(
                                      item.icon,
                                      size: 34,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    item.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.navy,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    item.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 13,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(tutorials.length, (index) {
                            final isActive = index == currentIndex;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 20 : 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppTheme.primary
                                    : AppTheme.border,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _finishTutorial,
                              child: const Text("Skip"),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: _nextPage,
                              child: Text(isLastPage ? "Continue" : "Next"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialItem {
  final IconData icon;
  final String title;
  final String description;

  const _TutorialItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}