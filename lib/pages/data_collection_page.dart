import 'package:flutter/material.dart';

class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            Column(
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Back"),
                          ),

                          const SizedBox(height: 8),

                          Image.asset(
                            'assets/images/healthphplusbarlogo.png',
                            height: 55,
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Data Collection",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),

                          const Text(
                            "Tracks symptoms & outbreaks",
                            style: TextStyle(fontSize: 12, color: Colors.indigo),
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
                            indicator: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.indigo,
                                  width: 3,
                                ),
                              ),
                            ),
                            tabs: [
                              Tab(text: "My Reports"),
                              Tab(text: "Community"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        Expanded(
                          child: TabBarView(
                            children: [_MyReportsTab(), _CommunityTab()],
                          ),
                        ),
                      ],
                    ),
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

class _MyReportsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text(
          "Your Recent Reports",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 12),

        ReportCard(
          symptom: "Fever",
          location: "Quezon City",
          duration: "3 days",
          severity: "Moderate",
          date: "Reported on May 5, 2025",
          comment: "Felt chills and body heat, especially at night.",
          icon: Icons.thermostat,
          severityColor: Color(0xFFE8C47C),
        ),

        ReportCard(
          symptom: "Cough",
          location: "Manila, NCR",
          duration: "3 days",
          severity: "Mild",
          date: "Reported on May 4, 2025",
          comment: "Dry cough, especially in the morning.",
          icon: Icons.sick,
          severityColor: Color(0xFFC9F2C7),
        ),

        InfoBox(),
      ],
    );
  }
}

class _CommunityTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        Text(
          "Community Reports",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        SizedBox(height: 4),

        Text(
          "View symptom reports shared by other users.",
          style: TextStyle(fontSize: 12),
        ),

        SizedBox(height: 12),

        ReportCard(
          symptom: "Fever",
          location: "NCR",
          duration: "2 days",
          severity: "Moderate",
          date: "Reported on May 6, 2025",
          comment: "User experienced fever and fatigue.",
          icon: Icons.thermostat,
          severityColor: Color(0xFFE8C47C),
        ),

        ReportCard(
          symptom: "Cough",
          location: "Region IV-A",
          duration: "4 days",
          severity: "Mild",
          date: "Reported on May 6, 2025",
          comment: "User reported dry cough and throat irritation.",
          icon: Icons.sick,
          severityColor: Color(0xFFC9F2C7),
        ),

        ReportCard(
          symptom: "Headache",
          location: "Region III",
          duration: "1 day",
          severity: "Mild",
          date: "Reported on May 5, 2025",
          comment: "User reported mild headache and tiredness.",
          icon: Icons.psychology,
          severityColor: Color(0xFFC9F2C7),
        ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  final String symptom;
  final String location;
  final String duration;
  final String severity;
  final String date;
  final String comment;
  final IconData icon;
  final Color severityColor;

  const ReportCard({
    super.key,
    required this.symptom,
    required this.location,
    required this.duration,
    required this.severity,
    required this.date,
    required this.comment,
    required this.icon,
    required this.severityColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: const Color(0xFFD7E9FF),
                  child: Icon(icon, size: 34, color: Colors.black),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "📍 $location",
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        "Duration: $duration",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    severity,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"$comment"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                date,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD8F7FA),
        border: Border.all(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Why Report Symptoms\nYour reports help public health officials track and monitor its origin.",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
