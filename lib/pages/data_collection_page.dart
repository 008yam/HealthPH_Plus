import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:healthphplus/main_page.dart';
import '../services/self_report_store.dart';
import '../services/location_data_services.dart';
import '../widgets/location_autocomplete_field.dart';
import '../services/profile_store.dart';
import '../services/geocoding_service.dart';
import '../theme/responsive.dart';
import '../services/self_report_database.dart';

class DataCollectionPage extends StatelessWidget {
  const DataCollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
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
                    margin: EdgeInsets.all(Responsive.pagePadding(context) * 0.8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            isScrollable: Responsive.isSmallPhone(context),
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
                              Tab(text: "Self Report"),
                              Tab(text: "My Reports"),
                              Tab(text: "Community"),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        Expanded(
                          child: TabBarView(
                            children: [_SelfReportTab(), _MyReportsTab(), _CommunityTab()],
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
    return AnimatedBuilder(
      animation: SelfReportStore.instance,
      builder: (context, _) {
        final reports = SelfReportStore.instance.reports;

        if (reports.isEmpty) {
          return ListView(
            children: const [
              Text(
                "Your Recent Reports",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                "No self-reports submitted yet.",
                style: TextStyle(fontSize: 12),
              ),
              InfoBox(),
            ],
          );
        }

        return ListView(
          children: [
            const Text(
              "Your Recent Reports",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...reports.map((report) {
              return ReportCard(
                symptom: report.symptoms.join(", "),
                location: report.locationLabel,
                duration: "Self-reported",
                severity: "For review",
                date: report.reportedAtLabel,
                comment: report.notes.isEmpty
                    ? "No additional notes provided."
                    : report.notes,
                consideration: report.possibleCondition,
                icon: Icons.assignment_turned_in,
                severityColor: const Color(0xFFDDE6FF),
              );
            }),

            const InfoBox(),
          ],
        );
      },
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

class _SelfReportTab extends StatefulWidget {
  @override
  State<_SelfReportTab> createState() => _SelfReportTabState();
}

class _SelfReportTabState extends State<_SelfReportTab> {
  final notesController = TextEditingController();
  
  bool locationLoaded = false;
  bool reportSubmitting = false;
  LocationOption? selectedRegion;
  LocationOption? selectedProvince;
  LocationOption? selectedCity;
  LocationOption? selectedBarangay;

  LocationDataService get locationService => LocationDataService.instance;

  List<LocationOption> get provinceOption =>
    locationService.provincesForRegion(selectedRegion?.code);

  List<LocationOption> get cityOptions =>
    locationService.citiesForProvince(
      selectedRegion?.code,
      selectedProvince?.code,
    );

  List<LocationOption> get barangayOptions =>
    locationService.barangaysForCity(
      selectedRegion?.code,
      selectedProvince?.code,
      selectedCity?.code,
    );

  final Set<String> selectedSymptoms = {};
  
  final symptoms = const [
    "Cough",
    "Fever",
    "Chills",
    "Fatigue",
    "Shortness of breath",
    "Chest Pain",
    "Sore throat",
    "Runny nose",
    "Wheezing",
    "Cough for 2+ weeks",
    "Night sweats",
    "Weight loss",
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    await locationService.load();

    final profile = ProfileStore.instance.profile;

    if (profile != null && profile.hasAddress) {
      selectedRegion = locationService.regions
          .where((item) => item.code == profile.regionCode)
          .firstOrNull;

      selectedProvince = locationService
          .provincesForRegion(selectedRegion?.code)
          .where((item) => item.name == profile.province)
          .firstOrNull;

      selectedCity = locationService
          .citiesForProvince(selectedRegion?.code, selectedProvince?.code)
          .where((item) => item.name == profile.city)
          .firstOrNull;
      
      selectedBarangay = locationService
          .barangaysForCity(selectedRegion?.code, selectedProvince?.code, selectedCity?.code)
          .where((item) => item.name == profile.barangay)
          .firstOrNull;
    }

    if(!mounted) return;

    setState(() {
      locationLoaded = true;
    });
  }
  
  @override
  void dispose() {
    // locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  String _possibleCondition() {
    final s = selectedSymptoms;
    if (s.contains("Cough") &&
       s.contains("Fever") &&
       s.contains("Chills") &&
       s.contains("Fatigue")) {
      return "POssible pneumonia pattern";
    }

    if (s.contains("Cough for 2+ weeks") ||
        (s.contains("Cough") &&
            s.contains("Night sweats") &&
            s.contains("Weight loss"))) {
        return "Possible tuberculosis symptom pattern";
            }
    if (s.contains("Cough for 2+ weeks") ||
          (s.contains("Cough") &&
            s.contains("Night sweats") &&
            s.contains("Weight loss"))) {
        return "Possible tuberculosis symptom pattern";
      }
    if (s.contains("Cough") || s.contains("Sore throat") || s.contains("Runny nose")) {
      return "Possible acute respiratory infection pattern";
    }

    return "Respiratory symptoms reported";
  }

  Future<void> _submitReport() async {
    if (reportSubmitting) return;

    if (selectedRegion == null ||
        selectedProvince == null ||
        selectedCity == null ||
        selectedBarangay == null ||
        selectedSymptoms.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Complete address and add at least one symptoms")),
          );
          return;
        }
    
    setState(() {
      reportSubmitting = true;
    });

    final condition = _possibleCondition();

    final geocoded = await GeocodingService.instance.geocodePhilippinesAddress(
      barangay: selectedBarangay!.name,
      city: selectedCity!.name,
      province: selectedProvince!.name,
    );

    if (!mounted) return;

    setState(() {
      reportSubmitting = false;
    });

    final report = SelfReport(
      region: selectedRegion!.code,
      province: selectedProvince!.name,
      city: selectedCity!.name,
      barangay: selectedBarangay!.name,
      latitude: geocoded?.latitude,
      longitude: geocoded?.longitude,
      geocodedAddress: geocoded?.displayName,
      symptoms: selectedSymptoms.toList(),
      possibleCondition: condition,
      notes: notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    SelfReportStore.instance.addReport(report);
    await SelfReportDatabase.instance.insertReport(report);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(condition),
        content: const Text(
          "This is not a diagnosis. Please consult a healthcare provider, especially if symptoms worsen.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Understood"),
          ),
        ],
      ),
    );

    setState(() {
      notesController.clear();
      selectedSymptoms.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text(
          "Self Report Symptoms",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Report respiratory symptoms to supper surveillance mapping.",
          style: TextStyle(fontSize: 12),
        ),

        const SizedBox(height: 14),

        if (!locationLoaded)
          const Center(child: CircularProgressIndicator())
          else ...[
            LocationAutocompleteField(
              label: "Region",
              icon: Icons.map_outlined,
              enabled: true,
              value: selectedRegion,
              options: locationService.regions,
              onSelected: (value) {
                setState(() {
                  selectedRegion = value;
                  selectedProvince = null;
                  selectedCity = null;
                  selectedBarangay = null;
                });
              },
            ),

            const SizedBox(height: 12),

            LocationAutocompleteField(
            label: "Province",
            icon: Icons.location_city_outlined,
            enabled: selectedRegion != null,
            value: selectedProvince,
            options: provinceOption,
            onSelected: (value) {
              setState(() {
                selectedProvince = value;
                selectedCity = null;
                selectedBarangay = null;
              });
            },
          ),

          const SizedBox(height: 12),

          LocationAutocompleteField(
            label: "City / Municipality",
            icon: Icons.apartment_outlined,
            enabled: selectedProvince != null,
            value: selectedCity, 
            options: cityOptions,
            onSelected: (value) {
              setState(() {
                selectedCity = value;
                selectedBarangay = null;
              });
            },
          ),

          const SizedBox(height: 12),

          LocationAutocompleteField(
            label: "Barangay",
            icon: Icons.home_work_outlined,
            enabled: selectedCity != null,
            value: selectedBarangay,
            options: barangayOptions,
            onSelected: (value) {
              setState(() {
                selectedBarangay = value;
              });
            },
          ),
        ],
        
        const SizedBox(height: 12),

        const Text(
          "Symptoms",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms.map((symptom) {
              final selected = selectedSymptoms.contains(symptom);

              return FilterChip(
              label: Text(symptom),
              selected: selected,
              selectedColor: AppTheme.primary.withValues(alpha: 0.16),
              checkmarkColor: AppTheme.primary,
              onSelected: (checked) {
                setState(() {
                  if (checked) {
                    selectedSymptoms.add(symptom);
                  } else {
                    selectedSymptoms.remove(symptom);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 14),

        TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Additional notes (optional)",
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 16),
  
        SizedBox(
          height: 46,
          child: ElevatedButton.icon(
            onPressed: reportSubmitting ? null : _submitReport,
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(reportSubmitting ? "Location Address..." : "Submit Self Report"),
        ),
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
  final String? consideration;
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
    this.consideration,
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

            if (consideration != null && consideration!.trim().isNotEmpty) ... [
              const SizedBox(height: 10,),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  border: Border.all(color: AppTheme.warning),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Possible / Consideration: $consideration",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text,
                  ),
                ),
              ),
            ],

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
