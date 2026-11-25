import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/widgets/floating_navbar.dart';
import 'pages/health_literacy_page.dart';
import 'pages/data_collection_page.dart';
import 'pages/disease_watch_page.dart';
import 'theme/app_theme.dart';
import 'theme/responsive.dart';
import 'widgets/coach_mark.dart';
import 'services/api_config.dart';
import 'services/healthph_api_services.dart';
import 'models/mobile_alert.dart';
import 'services/sentiment_survey_service.dart';
import 'services/mobile_alert_service.dart';
import 'services/profile_store.dart';
import 'localization/app_translations.dart';
import 'widgets/home/home_surface.dart';
import 'widgets/home/home_health_tips.dart';
import 'widgets/home/home_recent_alerts.dart';
import 'widgets/home/home_quick_actions.dart';
import 'widgets/home/home_contribution_actions.dart';
import 'widgets/home/home_stats_carousel.dart';

//import 'pages/map_page.dart';
//import 'widgets/floating_navbar.dart';

//import 'package:healthphplus/main_page_copy.dart';

// =======================================================
// HOME PAGE
// =======================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final headerKey = GlobalKey();
  final statsCarouselKey = GlobalKey();
  final contributionActionsKey = GlobalKey();
  final quickActionKey = GlobalKey();
  final recentAlertKey = GlobalKey();

  late Future<int> mobileUserCountFuture;

  late Future<MobileAlertsPage> mobileAlertsFuture;
  late Future<int> mobileAlertCountFuture;

  final mobileAlertService = MobileAlertService(baseUrl: ApiConfig.baseUrl);

  late final PageController _statsCarouselController;
  Timer? _statsCarouselTimer;
  int _statsCarouselIndex = 0;

  late Future<int> mobileSurveyCountFuture;

  static const int _statsCarouselItemCount = 3;
  @override
  void initState() {
    super.initState();
    _statsCarouselController = PageController(viewportFraction: 0.9);

    mobileSurveyCountFuture =
        SentimentSurveyService(baseUrl: ApiConfig.sentimentBaseUrl)
            .fetchPublicSurveys()
            .then((surveys) => surveys.length)
            .catchError((_) => 0);

    _startStatsCarousel();
    _loadMobileAlertFutures();
    mobileUserCountFuture = HealthPhApiService(
      baseUrl: ApiConfig.baseUrl,
    ).fetchMobileUsersCount();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;

        CoachMark.showOnce(
          context,
          discoveryKey: "main_page_v4",
          steps: [
            CoachMarkStep(
              targetKey: statsCarouselKey,
              title: "Live Health Summary",
              description:
                  "Swipe through current outbreaks, health alerts, registered users, and available mobile surveys.",
              icon: Icons.view_carousel_outlined,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: contributionActionsKey,
              title: "Your Contributions",
              description:
                  "Submit a self-report, review your previous reports, or answer an available mobile survey.",
              icon: Icons.assignment_outlined,
              color: AppTheme.success,
            ),
            CoachMarkStep(
              targetKey: quickActionKey,
              title: "Quick Actions",
              description:
                  "Open Disease Watch for outbreaks or Health Literacy for trusted learning resources.",
              icon: Icons.touch_app_outlined,
              color: AppTheme.info,
            ),
            CoachMarkStep(
              targetKey: recentAlertKey,
              title: "Recent Alerts",
              description:
                  "Review the latest respiratory health alerts and outbreaks",
              icon: Icons.notifications_active_outlined,
              color: AppTheme.warning,
            ),
          ],
        );
      });
    });
  }

  void _loadMobileAlertFutures() {
    mobileAlertsFuture = mobileAlertService.fetchAlerts(
      limit: 20,
      accessToken: ProfileStore.instance.profile?.accessToken,
    );
    mobileAlertCountFuture = mobileAlertsFuture
        .then((page) => page.items.length)
        .catchError((_) => 0);
  }

  void _refreshMobileAlerts() {
    if (!mounted) return;
    setState(_loadMobileAlertFutures);
  }

  Future<void> _openMobileAlert(MobileAlert summary) async {
    final token = ProfileStore.instance.profile?.accessToken;

    try {
      final detail = await mobileAlertService.fetchAlert(
        alertId: summary.id,
        accessToken: token,
      );

      try {
        await mobileAlertService.markAlertRead(
          alertId: summary.id,
          accessToken: token,
        );
        _refreshMobileAlerts();
      } catch (error) {
        debugPrint("Unable to mark mobile alert as read: $error");
      }

      if (!mounted) return;

      final published = detail.publishedAt?.toLocal();
      final publishedLabel = published == null
          ? "Publication time unavailable"
          : "Published ${published.year}-${published.month.toString().padLeft(2, '0')}-${published.day.toString().padLeft(2, '0')} "
                "${published.hour.toString().padLeft(2, '0')}:${published.minute.toString().padLeft(2, '0')}";

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(detail.title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.regionName.isNotEmpty
                        ? detail.regionName
                        : detail.region,
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.message.isEmpty
                        ? context.tr(
                            "No additional alert details were provided.",
                          )
                        : detail.message,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    publishedLabel,
                    style: const TextStyle(
                      color: AppTheme.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr("Close")),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      final message = error is MobileAlertAuthenticationException
          ? context.tr(error.toString())
          : "Unable to open this alert right now.";
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _startStatsCarousel() {
    _statsCarouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_statsCarouselController.hasClients) return;

      final nextIndex = (_statsCarouselIndex + 1) % _statsCarouselItemCount;

      _statsCarouselController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _statsCarouselTimer?.cancel();
    _statsCarouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                Responsive.pagePadding(context),
                Responsive.pagePadding(context),
                Responsive.pagePadding(context),
                Responsive.bottomNavClearance(context),
              ),
              child: HomeContentSurface(
                child: Column(
                  children: [
                    // ====================================================
                    // 1. HEADER SECTION
                    // ====================================================
                    KeyedSubtree(
                      key: headerKey,
                      child: SizedBox(
                        height: Responsive.verticalGap(
                          context,
                          36,
                          compact: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.verticalGap(context, 10)),

                    // ====================================================
                    // 2. TOP STATUS CARDS
                    // ====================================================
                    KeyedSubtree(
                      key: statsCarouselKey,
                      child: HomeStatsCarousel(
                        activeUserCountFuture: mobileUserCountFuture,
                        surveyCountFuture: mobileSurveyCountFuture,
                        alertCountFuture: mobileAlertCountFuture,
                        controller: _statsCarouselController,
                        selectedIndex: _statsCarouselIndex,
                        onPageChanged: (index) {
                          setState(() {
                            _statsCarouselIndex = index;
                          });
                        },
                        onHealthAlerts: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiseaseWatchPage(),
                            ),
                          );
                        },
                        onSurveys: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SentimentPulsePage(initialTabIndex: 3),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    // ====================================================
                    // 3. HEALTH CONTRIBUTION ACTIONS
                    // ====================================================
                    KeyedSubtree(
                      key: contributionActionsKey,
                      child: HomeContributionActions(
                        onDataCollection: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DataCollectionPage(),
                            ),
                          );
                        },
                        onSentimentPulse: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SentimentPulsePage(initialTabIndex: 3),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ====================================================
                    // 4. QUICK ACTIONS MENU
                    // ====================================================
                    KeyedSubtree(
                      key: quickActionKey,
                      child: HomeQuickActions(
                        onDiseaseWatch: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiseaseWatchPage(),
                            ),
                          );
                        },
                        onHealthLiteracy: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HealthLiteracyPage(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ====================================================
                    // 4. RECENT ALERTS SECTION
                    // ====================================================
                    KeyedSubtree(
                      key: recentAlertKey,
                      child: HomeRecentAlerts(
                        alertsFuture: mobileAlertsFuture,
                        onOpenAlert: _openMobileAlert,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // ====================================================
                    // 6. HEALTH TIP SECTION
                    // ====================================================
                    HomeHealthTips(
                      onViewMore: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HealthLiteracyPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 0),
    );
  }
}
