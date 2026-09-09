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
  double _pageOffset = 0;

  static const List<_TutorialItem> tutorials = [
    _TutorialItem(
      icon: Icons.coronavirus,
      title: "Disease Watch",
      description:
          "Monitor outbreak reports, active cases, and disease risk signals across regions.",
      accent: AppTheme.highRisk,
      softBackground: Color(0xFFFFF0F0),
    ),
    _TutorialItem(
      icon: Icons.map,
      title: "Disease Map",
      description:
          "View outbreak activity geographically and identify affected areas faster.",
      accent: AppTheme.info,
      softBackground: Color(0xFFEAF3FF),
    ),
    _TutorialItem(
      icon: Icons.article_outlined,
      title: "Health Literacy Hub",
      description:
          "Read evidence-based health articles and review fact-checking information.",
      accent: AppTheme.success,
      softBackground: Color(0xFFEAF7F1),
    ),
    _TutorialItem(
      icon: Icons.analytics,
      title: "Sentiment Pulse",
      description:
          "Understand public concern, misinformation, and health behavior trends.",
      accent: AppTheme.warning,
      softBackground: Color(0xFFFFF7E3),
    ),
    _TutorialItem(
      icon: Icons.assignment,
      title: "Data Collection",
      description:
          "Submit and review symptom reports that support public health monitoring.",
      accent: AppTheme.primary,
      softBackground: Color(0xFFEFF2FF),
    ),
  ];

  bool get isLastPage => currentIndex == tutorials.length - 1;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handlePageScroll);
  }

  void _handlePageScroll() {
    final page = _controller.page;
    if (page == null || (page - _pageOffset).abs() < 0.001) return;

    setState(() {
      _pageOffset = page;
    });
  }

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
    _controller.removeListener(_handlePageScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final tutorialHeight =
        (MediaQuery.sizeOf(context).height * (isTablet ? 0.38 : 0.32))
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
    final activeTutorial = tutorials[currentIndex];
    final activeAccent = activeTutorial.accent;
    final activeSoftBackground = activeTutorial.softBackground;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
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
                        constraints: BoxConstraints(maxWidth: cardMaxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/healthphbarlogowhite.png',
                              width: isTablet ? 420 : 280,
                              height: logoHeight,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: isTablet ? 36 : 28),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOut,
                              width: double.infinity,
                              padding: EdgeInsets.all(cardPadding),
                              decoration: BoxDecoration(
                                color: activeSoftBackground,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: activeAccent.withValues(alpha: 0.35),
                                ),
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
                                        final pageDelta = (_pageOffset - index)
                                            .clamp(-1.0, 1.0)
                                            .toDouble();
                                        final visibility = (1 - pageDelta.abs())
                                            .clamp(0.0, 1.0)
                                            .toDouble();
                                        final scale =
                                            0.92 + (visibility * 0.08);
                                        final opacity =
                                            0.55 + (visibility * 0.45);

                                        return Transform.scale(
                                          scale: scale,
                                          child: Opacity(
                                            opacity: opacity,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Transform.translate(
                                                  offset: Offset(
                                                    pageDelta * 42,
                                                    pageDelta.abs() * -6,
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: iconRadius,
                                                    backgroundColor: item.accent
                                                        .withValues(
                                                          alpha: 0.14,
                                                        ),
                                                    child: Icon(
                                                      item.icon,
                                                      size: iconSize,
                                                      color: item.accent,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                Transform.translate(
                                                  offset: Offset(
                                                    pageDelta * 28,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    item.title,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppTheme.navy,
                                                      fontSize: titleSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Transform.translate(
                                                  offset: Offset(
                                                    pageDelta * 16,
                                                    0,
                                                  ),
                                                  child: Text(
                                                    item.description,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: AppTheme.mutedText,
                                                      fontSize: descriptionSize,
                                                      height: 1.45,
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
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(tutorials.length, (
                                      index,
                                    ) {
                                      final isActive = index == currentIndex;

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        width: isActive ? 20 : 7,
                                        height: isTablet ? 8 : 7,
                                        decoration: BoxDecoration(
                                          color: isActive
                                              ? activeAccent
                                              : AppTheme.border,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
                                          minimumSize: Size(
                                            isTablet ? 96 : 72,
                                            buttonHeight,
                                          ),
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
                                          backgroundColor: activeAccent,
                                          foregroundColor: Colors.white,
                                          minimumSize: Size(
                                            isTablet ? 140 : 104,
                                            buttonHeight,
                                          ),
                                          textStyle: TextStyle(
                                            fontSize: isTablet ? 16 : 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        child: Text(
                                          isLastPage ? "Continue" : "Next",
                                        ),
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
  final Color accent;
  final Color softBackground;

  const _TutorialItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
    required this.softBackground,
  });
}
