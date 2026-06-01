import 'package:flutter/material.dart';
import 'package:healthphplus/login_page.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/widgets/floating_navbar.dart';
import 'pages/health_literacy_page.dart';
import 'pages/data_collection_page.dart';
import 'pages/disease_watch_page.dart';
import 'widgets/weather_widget.dart';
//import 'pages/map_page.dart';
//import 'widgets/floating_navbar.dart';

//import 'package:healthphplus/main_page_copy.dart';

// =======================================================
// HOME PAGE
// =======================================================

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4C98),
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
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // ====================================================
                  // 1. HEADER SECTION
                  // ====================================================
                  Container(
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
                          height: 55,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.person_outline,
                            color: Colors.indigo,
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // ====================================================
                  // 2. TOP STATUS CARDS
                  // ====================================================
                  const Row(
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
                          label: "Active Users",
                          icon: Icons.groups,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ====================================================
                  // 3. WEATHER WIDGET
                  // ====================================================
                  const WeatherWidget(),

                  const SizedBox(height: 6),

                  // ====================================================
                  // 4. QUICK ACTIONS MENU
                  // ====================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
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

                  const SizedBox(height: 8),

                  // ====================================================
                  // 4. RECENT ALERTS SECTION
                  // ====================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: cardDecoration(),
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

                  const SizedBox(height: 8),

                  // ====================================================
                  // 6. HEALTH TIP SECTIONS
                  // ====================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
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
                          padding: const EdgeInsets.all(10),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          const FloatingNavBar(selectedIndex: 1),
        ],
      ),
    );
  }
}

// =======================================================
// REUSABLE CARD DECORATION
// =======================================================

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.black),
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
      height: 78,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF31459B),
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),

          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8,
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

        Text(label, style: const TextStyle(fontSize: 8)),
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

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),

                  Text(subtitle, style: const TextStyle(fontSize: 8)),
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
        color: const Color(0xFADADADD),
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          ),

          Text(location, style: const TextStyle(fontSize: 8)),

          const SizedBox(height: 6),

          Stack(
            children: [
              Container(
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B4C98),
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 18,
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

          const SizedBox(height: 3),

          const Row(
            children: [
              Text("Severity Levels", style: TextStyle(fontSize: 8)),

              Spacer(),

              Text(
                "View Details",
                style: TextStyle(
                  fontSize: 8,
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
