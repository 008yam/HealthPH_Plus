  import 'package:flutter/material.dart';
  import '../services/healthph_api_services.dart';
  import '../theme/app_theme.dart';
  import 'package:healthphplus/main_page.dart';
  import '../theme/responsive.dart';

  class DiseaseWatchPage extends StatefulWidget {
    const DiseaseWatchPage({super.key});

    @override
    State<DiseaseWatchPage> createState() => _DiseaseWatchPageState();
  }

  class _DiseaseWatchPageState extends State<DiseaseWatchPage> {
    final TextEditingController _searchController = TextEditingController();

    String searchQuery = "";
    String selectedDisease = "All";

    late Future<Map<String, dynamic>> diseaseFuture;

    final List<Map<String, dynamic>> outbreaks = [
      {
        "title": "Respiratory Infection Cluster",
        "location": "Manila City - Respiratory",
        "percent": 21,
        "reports": 42,
        "category": "Upper Respiratory Disease",
      },
      {
        "title": "Pneumonia",
        "location": "Laguna Province - Respiratory",
        "percent": 14,
        "reports": 28,
        "category": "Pneumonia",
      },
      {
        "title": "Tuberculosis",
        "location": "Bulacan Province - Respiratory",
        "percent": 7.5,
        "reports": 15,
        "category": "Tuberculosis",
      },
    ];

    List<Map<String, dynamic>> get filteredOutbreaks {
      return outbreaks.where((outbreak) {
        final title = outbreak["title"].toString().toLowerCase();
        final location = outbreak["location"].toString().toLowerCase();
        final category = outbreak["category"].toString().toLowerCase();

        final matchesSearch =
            title.contains(searchQuery) ||
            location.contains(searchQuery) ||
            category.contains(searchQuery);

        final matchesCategory =
            selectedDisease == "All" ||
            outbreak["category"].toString() == selectedDisease;

        return matchesSearch && matchesCategory;
      }).toList();
    }

    @override
    void initState() {
      super.initState();

    diseaseFuture = HealthPhApiService(
      baseUrl: 'http://10.0.2.2:8000',
    ).fetchDiseasePoints();
  }


    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final int activeCount = filteredOutbreaks.length;

      return Scaffold(
        backgroundColor: AppTheme.pageBlue,
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Backdrop2.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.18),
              ),
            ),

            Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MainPage(),
                                  ),
                                );
                              }
                            },
                            child: const Text("Back"),
                          ),

                          const SizedBox(height: 8),

                          Image.asset(
                            'assets/images/healthphplusbarlogo.png',
                            height: 55,
                          ),

                          const Text(
                            "Disease Watch",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF243B8F),
                            ),
                          ),

                          const Text(
                            "Outbreak monitoring across the Philippines",
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF243B8F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(18, 14, 18, 20),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    searchQuery = value.toLowerCase().trim();
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: "Find Diseases",
                                  hintStyle: const TextStyle(fontSize: 11),
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: selectedDisease,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF2F2F2),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: "All",
                                    child: Text(
                                      "Select all that apply",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "AURI",
                                    child: Text(
                                      "AURI",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "PN",
                                    child: Text(
                                      "Pneumonia",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "TB",
                                    child: Text(
                                      "Tuberculosis",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "COVID",
                                    child: Text(
                                      "COVID",
                                      style: TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedDisease = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  color: const Color(0xFFF3F3F3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Active Outbreaks",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.redAccent,
                                        child: Text(
                                          "$activeCount",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "Resolved",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Expanded(
                          child: FutureBuilder<Map<String, dynamic>> (
                            future: diseaseFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    "Error: ${snapshot.error}",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              final apiData = snapshot.data!;
                              final regions =apiData["data"] as List;

                              final filteredRegions = regions.where((region) {
                                final regionName = region ["region"].toString().toLowerCase();
                                final annotations = List<String>.from(region["annotations"] ?? []);
                                final annotationsText = annotations.join(" ").toLowerCase();

                                final matchesSearch =
                                  regionName.contains(searchQuery) ||
                                  annotationsText.contains(searchQuery);

                                final matchesCategory =
                                  selectedDisease == "All" ||
                                  annotations.contains(selectedDisease);

                                return matchesSearch && matchesCategory;
                              }).toList();

                              if(filteredRegions.isEmpty) {
                                return const Center(
                                  child: Text(
                                    "No outbreaks found.",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                );
                              }
                              return ListView.builder(
                                itemCount: filteredRegions.length,
                                itemBuilder: (context, index) {
                                  final region =filteredRegions[index];
                                  final counts = region["annotations_count"];

                                  final int auri = counts["AURI"] ?? 0;
                                  final int pn = counts["PN"] ?? 0;
                                  final int tb = counts["TB"] ?? 0;
                                  final int covid = counts["COVID"] ?? 0;

                                  final int totalReports = auri + pn + tb + covid;

                                  return OutbreakCard(
                                    title: "Region ${region["region"]}",
                                    location: "AURI: $auri | PN: $pn | TB: $tb | COVID: $covid",
                                    percent: totalReports,
                                    reports: totalReports,
                                    );
                                },
                              );
                            },
                          )
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  class OutbreakCard extends StatelessWidget {
    final String title;
    final String location;
    final num percent;
    final int reports;

    const OutbreakCard({
      super.key,
      required this.title,
      required this.location,
      required this.percent,
      required this.reports,
    });

    @override
    Widget build(BuildContext context) {
      final double progress = (percent / 30).clamp(0.08, 1.0);

      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 28,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(right: 18),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Stack(
                    children: [
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE25A),
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F3D91),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              "$percent%",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Severity Levels",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$reports reports",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "View Details",
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF243B8F),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
