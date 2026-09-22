import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/widgets/floating_navbar.dart';
import 'pages/health_literacy_page.dart';
import 'pages/data_collection_page.dart';
import 'pages/disease_watch_page.dart';
import 'widgets/weather_widget.dart';
import 'theme/app_theme.dart';
import 'theme/responsive.dart';
import 'widgets/coach_mark.dart';
import 'services/api_config.dart';
import 'services/healthph_api_services.dart';
import 'models/mobile_alert.dart';
import 'services/sentiment_survey_service.dart';
import 'services/mobile_alert_service.dart';
import 'services/profile_store.dart';
import 'widgets/app_skeleton.dart';

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

  static const int _statsCarouselItemCount = 4;
  @override
  void initState() {
    super.initState();
    _statsCarouselController = PageController(viewportFraction: 0.9);

    mobileSurveyCountFuture = SentimentSurveyService(baseUrl: ApiConfig.baseUrl)
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
          discoveryKey: "main_page_v2",
          steps: [
            CoachMarkStep(
              targetKey: headerKey,
              title: "HealthPH+ Home",
              description:
                  "This is your main dashboard for respiratory health updates",
              icon: Icons.home,
              color: AppTheme.primary,
            ),
            CoachMarkStep(
              targetKey: quickActionKey,
              title: "Quick Actions",
              description:
                  "Open Disease, Health Literacy, Sentiment Pulse, Data Collection",
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
                        ? "No additional alert details were provided."
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
                child: const Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      final message = error is MobileAlertAuthenticationException
          ? error.toString()
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
              child: _HomeContentSurface(
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
                    _buildStatsCarousel(),
                    const SizedBox(height: 14),
                    // ====================================================
                    // 3. WEATHER WIDGET
                    // ====================================================
                    const WeatherWidget(),
                    const SizedBox(height: 16),
                    // ====================================================
                    // 4. QUICK ACTIONS MENU
                    // ====================================================
                    KeyedSubtree(
                      key: quickActionKey,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        decoration: cardDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Quick Actions ⓘ",
                              style: TextStyle(
                                color: AppTheme.text,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 8),

                            QuickActionTile(
                              title: "Disease Watch",
                              subtitle: "Track outbreaks and alerts",
                              icon: Icons.coronavirus,
                              iconColor: Colors.redAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DiseaseWatchPage(),
                                  ),
                                );
                              },
                            ),
                            QuickActionTile(
                              title: "Health Literacy",
                              subtitle: "Public attitude insights",
                              icon: Icons.article_outlined,
                              iconColor: Colors.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HealthLiteracyPage(),
                                  ),
                                );
                              },
                            ),

                            QuickActionTile(
                              title: "Sentiment Pulse",
                              subtitle: "Public attitude insights",
                              icon: Icons.analytics,
                              iconColor: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SentimentPulsePage(),
                                  ),
                                );
                              },
                            ),

                            QuickActionTile(
                              title: "Data Collection",
                              subtitle: "Report symptoms & data",
                              icon: Icons.assignment,
                              iconColor: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DataCollectionPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ====================================================
                    // 4. RECENT ALERTS SECTION
                    // ====================================================
                    KeyedSubtree(
                      key: recentAlertKey,
                      child: FutureBuilder<MobileAlertsPage>(
                        future: mobileAlertsFuture,
                        builder: (context, snapshot) {
                          final alerts = snapshot.data?.items ?? [];

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: cardDecoration(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Recent Alerts ⓘ",
                                  style: TextStyle(
                                    color: AppTheme.text,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                  const _RecentAlertsSkeleton()
                                else if (snapshot.hasError)
                                  Text(
                                    snapshot.error
                                            is MobileAlertAuthenticationException
                                        ? snapshot.error.toString()
                                        : "Unable to load alerts.",
                                    style: const TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else if (alerts.isEmpty)
                                  const Text(
                                    "No recent alerts right now.",
                                    style: TextStyle(
                                      color: AppTheme.mutedText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                else
                                  ...alerts
                                      .take(3)
                                      .map(
                                        (alert) => AlertCard(
                                          title: alert.title,
                                          location: alert.locationLabel,
                                          percent: "${alert.reportCount}",
                                          metricLabel: alert.countLabel,
                                          progress: alert.progress,
                                          onTap: () => _openMobileAlert(alert),
                                        ),
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ====================================================
                    // 6. HEALTH TIP SECTIONS
                    // ====================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      decoration: cardDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Health Tips 📖",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9F8D8),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Stay Protected",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Text(
                                  "Remember to wash your hands frequently, weak mask in crowded places, and keep your living spaces well-ventilated",
                                  style: TextStyle(fontSize: 10),
                                ),

                                const SizedBox(height: 8),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: SizedBox(
                                    height: 36,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HealthLiteracyPage(),
                                          ),
                                        );
                                      },
                                      child: const Text("More Health Tips"),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 1),
    );
  }

  Widget _buildStatsCarousel() {
    final isLandscapePhone = Responsive.isLandscapePhone(context);
    final carouselHeight = isLandscapePhone ? 92.0 : 112.0;

    return FutureBuilder<int>(
      future: mobileUserCountFuture,
      builder: (context, userSnapshot) {
        return FutureBuilder<int>(
          future: mobileSurveyCountFuture,
          builder: (context, surveySnapshot) {
            return FutureBuilder<int>(
              future: mobileAlertCountFuture,
              builder: (context, alertSnapshot) {
                final activeUsers = userSnapshot.hasData
                    ? userSnapshot.data.toString()
                    : userSnapshot.hasError
                    ? "0"
                    : "...";

                final alertCount = alertSnapshot.hasData
                    ? alertSnapshot.data.toString()
                    : alertSnapshot.hasError
                    ? "0"
                    : "...";

                final surveyCount = surveySnapshot.hasData
                    ? surveySnapshot.data.toString()
                    : surveySnapshot.hasError
                    ? "0"
                    : "...";

                final cards = [
                  _CarouselStatCard(
                    number: "3",
                    label: "Active Outbreaks",
                    subtitle: "Regional disease signals",
                    icon: Icons.coronavirus,
                    accentColor: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DiseaseWatchPage(),
                        ),
                      );
                    },
                  ),
                  _CarouselStatCard(
                    number: alertCount,
                    label: "Health Alerts",
                    subtitle: "Recent inbox alerts",
                    icon: Icons.local_hospital,
                    accentColor: AppTheme.warning,
                  ),
                  _CarouselStatCard(
                    number: activeUsers,
                    label: "Active Users",
                    subtitle: "Registered mobile users",
                    icon: Icons.groups,
                    accentColor: AppTheme.success,
                  ),
                  _CarouselStatCard(
                    number: surveyCount,
                    label: "Mobile Surveys",
                    subtitle: "Available public surveys",
                    icon: Icons.poll_outlined,
                    accentColor: AppTheme.info,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const SentimentPulsePage(initialTabIndex: 3),
                        ),
                      );
                    },
                  ),
                ];

                return Column(
                  children: [
                    SizedBox(
                      height: carouselHeight,
                      child: PageView.builder(
                        controller: _statsCarouselController,
                        itemCount: cards.length,
                        onPageChanged: (index) {
                          setState(() {
                            _statsCarouselIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: cards[index],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(cards.length, (index) {
                        final selected = index == _statsCarouselIndex;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: selected ? 18 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary
                                : AppTheme.border,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _RecentAlertsSkeleton extends StatelessWidget {
  const _RecentAlertsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 15, width: 210),
              SizedBox(height: 8),
              AppSkeleton(height: 12, width: 145),
              SizedBox(height: 14),
              AppSkeleton(height: 10, width: double.infinity),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeContentSurface extends StatelessWidget {
  final Widget child;

  const _HomeContentSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.contentMaxWidth(context),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: AppTheme.text),
          child: child,
        ),
      ),
    );
  }
}

// =======================================================
// REUSABLE CARD DECORATION
// =======================================================

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: AppTheme.surfaceSoft,
    border: Border.all(color: AppTheme.border),
    borderRadius: BorderRadius.circular(12),
  );
}

// =======================================================
// CAROUSEL STAT CARDS WIDGET
// =======================================================
class _CarouselStatCard extends StatelessWidget {
  final String number;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _CarouselStatCard({
    required this.number,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(isLandscapePhone ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor, AppTheme.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -22,
                child: Icon(
                  icon,
                  size: isLandscapePhone ? 76 : 96,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: isLandscapePhone ? 20 : 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: isLandscapePhone ? 22 : 26,
                    ),
                  ),
                  SizedBox(width: isLandscapePhone ? 10 : 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          number,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscapePhone ? 24 : 30,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        SizedBox(height: isLandscapePhone ? 3 : 5),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isLandscapePhone ? 13 : 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.82),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// =======================================================
// TOP STATUS CARD WIDGET
// =======================================================

class TopStatCard extends StatelessWidget {
  final String number;
  final String label;
  final IconData icon;

  const TopStatCard({
    super.key,
    required this.number,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = Responsive.isLandscapePhone(context)
        ? 64.0
        : (Responsive.isSmallPhone(context) ? 72.0 : 78.0);

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(6),
        image: const DecorationImage(
          image: AssetImage('assets/images/Backdrop1.png'),
          fit: BoxFit.cover,
          opacity: 0.18,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 17),

          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// WEATHER SMALL INFO WIDGET
// =======================================================

class WeatherSmallInfo extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const WeatherSmallInfo({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.black87),

        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

// =======================================================
// QUICK ACTION TILE WIDGET
// =======================================================

class QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: iconColor.withValues(alpha: 0.18),
                child: Icon(icon, size: 18, color: iconColor),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.text,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================================================
// ALERT CARD WIDGET
// =======================================================
class AlertCard extends StatelessWidget {
  final String title;
  final String location;
  final String percent;
  final String? metricLabel;
  final double progress;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.title,
    required this.location,
    required this.percent,
    this.metricLabel,
    required this.progress,
    this.onTap,
  });

  String get _percentLabel {
    final metric = metricLabel?.trim();
    if (metric != null && metric.isNotEmpty) return metric;

    final value = percent.trim();
    if (value.isEmpty) return "${(progress * 100).round()}%";
    return value;
  }

  Color get _severityColor {
    final cleaned = percent.replaceAll('%', '').trim();
    final value = double.tryParse(cleaned) ?? (progress * 100);
    if (value >= 20) return AppTheme.warning;
    if (value >= 10) return AppTheme.pageBlue;
    return AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _severityColor;
    final progressValue = progress.clamp(0.0, 1.0).toDouble();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: severityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: severityColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _percentLabel,
                        style: TextStyle(
                          color: severityColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(height: 8, color: AppTheme.progressTrack),
                      FractionallySizedBox(
                        widthFactor: progressValue,
                        child: Container(height: 8, color: severityColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Icon(
                      Icons.insights_outlined,
                      size: 15,
                      color: severityColor,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Severity level',
                      style: TextStyle(
                        color: AppTheme.mutedText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'View Details',
                      style: TextStyle(
                        color: AppTheme.info,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
