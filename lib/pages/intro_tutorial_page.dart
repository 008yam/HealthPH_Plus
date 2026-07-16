import 'package:flutter/material.dart';
import '../main_page.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';

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
    final isTablet = Responsive.isTablet(context);
    final tutorialHeight = (MediaQuery.sizeOf(context).height *
            (isTablet ? 0.38 : 0.32))
        .clamp(isTablet ? 320 : 230.0, isTablet ? 500.0 : 340.0)
        .toDouble();
    
    final cardMaxWidth = isTablet ? 720.0 : Responsive.formMaxWidth(context);
    final cardPadding = isTablet ? 36.0 : 18.0;
    final logoHeight = isTablet
        ? 104.0
        : (Responsive.isSmallPhone(context) ? 62.0 : 72.0);
    final iconRadius = isTablet ? 64.0 : 34.0;
    final iconSize = isTablet ? 48.0 : 34.0;
    final titleSize = isTablet ? 32.0 : 22.0;
    final descriptionSize = isTablet ? 18.0 : 13.0;
    final buttonHeight = isTablet ? 52.0 : 46.0; 

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.pagePadding(context),
                    16,
                    Responsive.pagePadding(context),
                    20,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: cardMaxWidth,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/healthphbarlogowhite.png',
                              width: isTablet ? 420 :280,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: isTablet ? 36 : 28),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(cardPadding),
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
                                    height: tutorialHeight,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            CircleAvatar(
                                              radius: iconRadius,
                                              backgroundColor: AppTheme.primary
                                                  .withValues(alpha: 0.12),
                                              child: Icon(
                                                item.icon,
                                                size: iconSize,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 18),
                                            Text(
                                              item.title,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.navy,
                                                fontSize: titleSize,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              item.description,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: AppTheme.mutedText,
                                                fontSize: descriptionSize,
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
                                    children:
                                        List.generate(tutorials.length, (index) {
                                      final isActive = index == currentIndex;

                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 220),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: isActive ? 20 : 7,
                                        height: isTablet ? 8 : 7,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? AppTheme.primary
                                              : AppTheme.border,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: _finishTutorial,
                                        style: TextButton.styleFrom(
                                          minimumSize: Size(isTablet ? 96 : 72, buttonHeight),
                                          textStyle: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        child: const Text("Skip"),
                                        ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: _nextPage,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(isTablet ? 140 : 104, buttonHeight),
                                          textStyle: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        child: Text(isLastPage ? "Continue" : "Next"),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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
