import 'package:flutter/material.dart';

// =======================================================
// HOME PAGE
// =======================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<String> carouselItems = [
    "Active Outbreaks",
    "Health Alerts",
    "Actives Users",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Respiratory Health Monitor"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // =======================================================
            // 1. CAROUSEL SECTION
            // =======================================================
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: carouselItems.length,
                controller: PageController(viewportFraction: 0.9),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          carouselItems[index],
                          style: const TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // =======================================================
            // 2. WEATHER WIDGET
            // =======================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Current Weather",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          WeatherInfo(
                            title: "Temp",
                            value: "31°C",
                            icon: Icons.thermostat,
                          ),

                          WeatherInfo(
                            title: "Humidity",
                            value: "75%",
                            icon: Icons.water_drop,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          WeatherInfo(
                            title: "AQI",
                            value: "85",
                            icon: Icons.air,
                          ),

                          WeatherInfo(
                            title: "Wind",
                            value: "15 km/h",
                            icon: Icons.wind_power,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =======================================================
            // 3. QUICK ACTIONS MENU
            // =======================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quick Actions",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      QuickActionButton(
                        title: "Disease Watch",
                        icon: Icons.coronavirus,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiseaseWatchPage(),
                            ),
                          );
                        },
                      ),

                      QuickActionButton(
                        title: "Health Literacy",
                        icon: Icons.menu_book,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HealthLiteracyPage(),
                            ),
                          );
                        },
                      ),

                      QuickActionButton(
                        title: "Sentiment Pulse",
                        icon: Icons.analytics,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SentimentPulsePage(),
                            ),
                          );
                        },
                      ),

                      QuickActionButton(
                        title: "Data Collection",
                        icon: Icons.assignment,
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =======================================================
            // 4. HEALTH TIPS SECTION
            // =======================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Health Tips",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      HealthTipCard(
                        tip:
                            "Wear a mask when air quality levels are unhealthy.",
                      ),

                      HealthTipCard(
                        tip:
                            "Stay hydrated to maintain healthy respiratory function.",
                      ),

                      HealthTipCard(
                        tip:
                            "Avoid outdoor activities during high pollution hours.",
                      ),

                      HealthTipCard(
                        tip:
                            "Regularly clean indoor air filters and ventilation.",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// WEATHER INFO WIDGET
// =======================================================

class WeatherInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const WeatherInfo({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 35, color: Colors.blue),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

// =======================================================
// QUICK ACTION BUTTON
// =======================================================

class QuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// =======================================================
// HEALTH TIP CARD
// =======================================================

class HealthTipCard extends StatelessWidget {
  final String tip;

  const HealthTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.health_and_safety, color: Colors.blue),
        title: Text(tip),
      ),
    );
  }
}

// =======================================================
// PAGES
// =======================================================

class DiseaseWatchPage extends StatelessWidget {
  const DiseaseWatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Disease Watch")),
      body: const Center(child: Text("Disease Watch Page")),
    );
  }
}

class HealthLiteracyPage extends StatelessWidget {
  const HealthLiteracyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Health Literacy")),
      body: const Center(child: Text("Health Literacy Page")),
    );
  }
}

class SentimentPulsePage extends StatelessWidget {
  const SentimentPulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sentiment Pulse")),
      body: const Center(child: Text("Sentiment Pulse Page")),
    );
  }
}

class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Data Collection")),
      body: const Center(child: Text("Data Collection Page")),
    );
  }
}
