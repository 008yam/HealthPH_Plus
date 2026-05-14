import 'package:flutter/material.dart';

class SentimentPulsePage extends StatelessWidget {
  const SentimentPulsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF3B4C98),
        body: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(45),
                  bottomRight: Radius.circular(45),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Back"),
                      ),
                      const SizedBox(height: 10),

                      Image.asset(
                        'assets/images/healthphplusbarlogo.png',
                        height: 55,
                      ),

                      const Text(
                        "Sentiment Pulse",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),

                      const Text(
                        "Evidence-based health infomration and fact-checking",
                        style: TextStyle(fontSize: 11, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const TabBar(
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.indigo,
                        tabs: [
                          Tab(text: "Overview"),
                          Tab(text: "Trends"),
                          Tab(text: "Regional"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Expanded(
                      child: TabBarView(
                        children: [OverviewTab(), TrendsTab(), RegionalTab()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text(
          "Overall Sentiment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 12),

        Row(
          children: [
            SentimentBox(
              percent: "45%",
              label: "Concerned",
              icon: Icons.sentiment_dissatisfied,
              color: Color(0xFFFFD98A),
            ),
            SizedBox(width: 8),
            SentimentBox(
              percent: "28%",
              label: "Misinformed",
              icon: Icons.warning_amber_rounded,
              color: Color(0xFFFFB3B3),
            ),
          ],
        ),

        SizedBox(height: 8),

        Row(
          children: [
            SentimentBox(
              percent: "18%",
              label: "Neutral",
              icon: Icons.sentiment_neutral,
              color: Color(0xFFBBD7FF),
            ),
            SizedBox(width: 8),
            SentimentBox(
              percent: "9%",
              label: "Proactive",
              icon: Icons.sentiment_satisfied_alt,
              color: Color(0xFFBDF2CD),
            ),
          ],
        ),

        SizedBox(height: 16),

        BarGraphCard(),
      ],
    );
  }
}

class TrendsTab extends StatelessWidget {
  const TrendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text(
          "Sentiment Trends",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Text("Sentiment changes over time", style: TextStyle(fontSize: 12)),

        SizedBox(height: 12),

        TrendLineCard(),

        SizedBox(height: 16),

        Text(
          "Trends Insights",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8),

        Row(
          children: [
            InsightCard(
              title: "Concerned",
              value: "+6%",
              description: 'Increase from last week',
              color: Color(0xFFFFE082),
            ),
            SizedBox(width: 8),
            InsightCard(
              title: "Proactive",
              value: "+6%",
              description: "Increase from last week",
              color: Color(0xFFC8E6C9),
            ),
          ],
        ),

        SizedBox(height: 16),

        Text(
          "Region Trend Changes",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 8),

        RegionMiniCard(region: "NCR", sentiment: "Concerned", change: "+6%"),
        RegionMiniCard(
          region: "Region III",
          sentiment: "Neutral",
          change: "+9%",
        ),
        RegionMiniCard(
          region: "Region V",
          sentiment: "Misinformed",
          change: "+6%",
        ),
      ],
    );
  }
}

class RegionalTab extends StatelessWidget {
  const RegionalTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text(
          "Regional Sentiment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        Text("Dominant sentiment by region", style: TextStyle(fontSize: 12)),

        SizedBox(height: 12),

        RegionalSentimentCard(
          region: "NCR",
          sentiment: "Concerned",
          percent: 45,
          color: Colors.amber,
        ),

        RegionalSentimentCard(
          region: "Region III",
          sentiment: 'Neutral',
          percent: 38,
          color: Colors.green,
        ),

        RegionalSentimentCard(
          region: "Regiono IV-A",
          sentiment: "Proactive",
          percent: 38,
          color: Colors.blue,
        ),

        RegionalSentimentCard(
          region: "Region VII",
          sentiment: "Concerned",
          percent: 48,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class SentimentBox extends StatelessWidget {
  final String percent;
  final String label;
  final IconData icon;
  final Color color;

  const SentimentBox({
    super.key,
    required this.percent,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    percent,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 42, color: Colors.indigo),
          ],
        ),
      ),
    );
  }
}

class BarGraphCard extends StatelessWidget {
  const BarGraphCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      {"label": "Concerned", "value": 45, "color": Colors.orange},
      {"label": "Misinfomred", "value": 28, "color": Colors.red},
      {"label": "Concerned", "value": 18, "color": Colors.blue},
      {"label": "Concerned", "value": 9, "color": Colors.green},
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final int value = item["value"] as int;
          final Color color = item["color"] as Color;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("$value%"),
                Container(height: value * 3, width: 38, color: color),
                const SizedBox(height: 6),
                Text(
                  item["label"].toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class TrendLineCard extends StatelessWidget {
  const TrendLineCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _trendRow("Concerned", "45% → 52%", Colors.amber),
          _trendRow("Neutral", "35% → 44%", Colors.amber),
          _trendRow("Proactive", "26% → 33%", Colors.amber),
          _trendRow("Misinformed", "16% → 24%", Colors.amber),
        ],
      ),
    );
  }

  static Widget _trendRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(width: 14, height: 14, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final String description;
  final Color color;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.45),
          border: Border.all(color: Colors.black26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(description, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class RegionMiniCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final String change;

  const RegionMiniCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        dense: true,
        title: Text(region),
        subtitle: Text(sentiment),
        trailing: Text(
          change,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class RegionalSentimentCard extends StatelessWidget {
  final String region;
  final String sentiment;
  final int percent;
  final Color color;

  const RegionalSentimentCard({
    super.key,
    required this.region,
    required this.sentiment,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(region, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percent / 100,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    sentiment,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  "$percent% of the population",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
