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

//import 'pages/map_page.dart';
//import 'widgets/floating_navbar.dart';

//import 'package:healthphplus/main_page_copy.dart';

// =======================================================
// HOME PAGE
// =======================================================

class MainPage extends StatefulWidget{
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final headerKey = GlobalKey();
  final quickActionKey = GlobalKey();
  final recentAlertKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;

        CoachMark.showOnce(
        context,
        discoveryKey: "main_page_v1",
        steps: [
          CoachMarkStep(
            targetKey: headerKey,
            title: "HealthPH+ Home",
            description: "This is your main dashboard for respiratory health updates",
            icon: Icons.home,
            color: AppTheme.primary
          ),
          CoachMarkStep(
            targetKey: quickActionKey,
            title: "Quick Actions",
            description: "Open Disease, Health Literacy, Sentiment Pulse, Data Collection",
            icon: Icons.touch_app_outlined,
            color: AppTheme.info
          ),
          CoachMarkStep(
            targetKey: recentAlertKey,
            title: "Recent Alerts",
            description: "Review the latest respiratory health alerts and outbreaks",
            icon: Icons.notifications_active_outlined,
            color: AppTheme.warning,
          ),
        ],
      );
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    final compactStats = MediaQuery.sizeOf(context).width < 380;
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.pagePadding(context)), //EdgeInsets.fromLTRB
              child: Column(
                children: [
                  // ====================================================
                  // 1. HEADER SECTION
                  // ====================================================
                  KeyedSubtree(
                    key: headerKey,
                    child: Container(
                      width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/healthphplusbarlogo.png',
                          height: Responsive.logoHeight(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
                  const SizedBox(height: 6),

                  // ====================================================
                  // 2. TOP STATUS CARDS
                  // ====================================================
                 compactStats
                    ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TopStatCard(
                          number: "3",
                          label: "Active Outbreaks",
                          icon: Icons.coronavirus,
                        ),
                        SizedBox(height: 6),
                        TopStatCard(
                          number: "1",
                          label: "Health Alerts",
                          icon: Icons.local_hospital,
                        ),
                        SizedBox(height: 6),
                        TopStatCard(
                          number: "2",
                          label: "Active Users",
                          icon: Icons.group,
                        ),
                      ],
                    )
                  : const Row(
                    children: [
                      Expanded(
                        child: TopStatCard(
                          number: "3",
                          label: "Active Outbreaks",
                          icon: Icons.coronavirus,
                        ),
                      ),
                       SizedBox(width: 6),
                      Expanded(
                        child: TopStatCard(
                          number: "1",
                          label: "Health Alerts",
                          icon: Icons.local_hospital,
                        ),
                      ),
                       SizedBox(width: 6),
                      Expanded(
                        child: TopStatCard(
                          number: "2",
                          label: "Active User",
                          icon: Icons.groups,
                        ),
                      ),
                    ],
                  ),
                  

                  // ====================================================
                  // 3. WEATHER WIDGET
                  // ====================================================
                  const WeatherWidget(),

                  const SizedBox(height: 6),

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
                    child: Container(
                      width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recent Alerts ⓘ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 8),

                        AlertCard(
                          title: "Respiratory Infection Cluster",
                          location: "Manila City . Respiratory",
                          percent: "21%",
                          progress: 0.75,
                        ),

                        AlertCard(
                          title: "Dengue Outbreak",
                          location: "Laguna Province . Vector Borne",
                          percent: "14",
                          progress: 0.55,
                        ),

                        AlertCard(
                          title: "Acute Upper Respiraory Infection",
                          location: "Bukidnon Province . Respiratory",
                          percent: "21%",
                          progress: 0.38,
                        ),
                      ],
                    ),
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
          ],
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 1),
    );
  }
}

// =======================================================
// REUSABLE CARD DECORATION
// =======================================================

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: AppTheme.border),
    borderRadius: BorderRadius.circular(8),
  );
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
    return Container(
      height: Responsive.isSmallPhone(context) ? 72 : 78,
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
          )
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
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
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
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
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
  final double progress;

  const AlertCard({
    super.key,
    required this.title,
    required this.location,
    required this.percent,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),

          Text(location, style: const TextStyle(fontSize: 10)),

          const SizedBox(height: 6),

          SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                Container(
                height: 10,
                decoration: BoxDecoration(
                  color:AppTheme.pageBlue,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      percent,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 3),

          const Row(
            children: [
              Text("Severity Levels", style: TextStyle(fontSize: 10)),

              Spacer(),

              Text(
                "View Details",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
