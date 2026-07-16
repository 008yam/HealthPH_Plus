import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:healthphplus/main_page.dart';
import 'data_collection_page.dart';
import 'disease_watch_page.dart';
import 'health_literacy_page.dart';
import 'sentiment_pulse_page.dart';
import 'settings_page.dart';
import '../services/healthph_api_services.dart';
import '../theme/app_theme.dart';
import '../services/self_report_store.dart';
import '../theme/responsive.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}


class _MapPageState extends State<MapPage> {
  static const Color _navy = Color(0xFF243B8F);
  static const Color _deepBlue = Color(0xFF31459B);
  static const Color _pageBlue = Color(0xFF3B4C98);
  static const Color _lightPurple = Color(0xFFDDE6FF);
  static const Color _yellow = Color(0xFFFFD84D);

  static const List<String> diseaseFilterOptions = [
    "AURI",
    "Cough",
    "Fever",
    "Sore throat",
    "Influenza-like illness",
    "Pneumonia",
    "Bronchitis",
    "Asthma flare-up",
    "Shortness of breath",
    "Wheezing",
    "COVID-like symptoms",
    "Tuberculosis symptoms",
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController mapController = MapController();

  final Set<String> selectedFilters = <String>{};

  final LatLng philippinesCenter = const LatLng(12.8797, 121.7740);

  final List<Map<String, dynamic>> outbreaks = [
    {
      "name": "Manila City",
      "disease": "Acute Upper Respiratory Infection",
      "category": "Upper Respiratory",
      "reports": 42,
      "updated": "Updated: June 1, 2026",
      "lat": 14.5995,
      "lng": 120.9842,
      "tags": [
        "AURI",
        "Cough",
        "Fever",
        "Sore throat",
        "Influenza-like illness",
        "COVID-like symptoms",
      ],
    },
    {
      "name": "Laguna Province",
      "disease": "Pneumonia",
      "category": "Lower Respiratory",
      "reports": 28,
      "updated": "Updated: May 31, 2026",
      "lat": 14.1709,
      "lng": 121.2446,
      "tags": [
        "Pneumonia",
        "Bronchitis",
        "Asthma flare-up",
        "Shortness of breath",
        "Wheezing",
        "Fever",
      ],
    },
    {
      "name": "Bulacan Province",
      "disease": "Tuberculosis",
      "category": "Respiratory",
      "reports": 15,
      "updated": "Updated: May 30, 2026",
      "lat": 14.7943,
      "lng": 120.8799,
      "tags": ["Tuberculosis symptoms", "Cough", "Shortness of breath"],
    },
  ];

    List<Map<String, dynamic>> get allOutbreaks {
    return [...outbreaks, ...SelfReportStore.instance.mapReports];
  }

    List<Map<String, dynamic>> get filteredOutbreaks {
    if (selectedFilters.isEmpty) return allOutbreaks;

    return allOutbreaks.where((outbreak) {
      final tags = List<String>.from(outbreak["tags"] ?? []);
      return tags.any(selectedFilters.contains);
    }).toList();
  }

  String get filterSummary {
    if (selectedFilters.isEmpty) return "All diseases & symptoms";

    final filterLabel = selectedFilters.length == 1 ? "filter" : "filters";
    return "${selectedFilters.length} $filterLabel selected";
  }

  void resetMapView() {
    final zoom = Responsive.isTablet(context) ? 6.15 : 5.5;
    mapController.move(philippinesCenter, zoom);
  }

  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }

  void _openDiseaseFilterSheet() {
    final draftFilters = Set<String>.from(selectedFilters);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final mediaQuery = MediaQuery.of(sheetContext);

            return Container(
              constraints: BoxConstraints(
                maxHeight: mediaQuery.size.height * 0.78,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Select Diseases / Symptoms",
                              style: TextStyle(
                                color: _navy,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: "Close",
                            onPressed: () => Navigator.pop(sheetContext),
                            icon: const Icon(Icons.close, color: _navy),
                          ),
                        ],
                      ),
                      Text(
                        draftFilters.isEmpty
                            ? "No filters selected. All reports will be shown."
                            : "${draftFilters.length} selected",
                        style: const TextStyle(
                          color: _deepBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: diseaseFilterOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 6),
                          itemBuilder: (context, index) {
                            final option = diseaseFilterOptions[index];
                            final isSelected = draftFilters.contains(option);

                            return Material(
                              color: isSelected
                                  ? _lightPurple.withValues(alpha: 0.65)
                                  : const Color(0xFFF7F8FF),
                              borderRadius: BorderRadius.circular(12),
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (checked) {
                                  setSheetState(() {
                                    if (checked ?? false) {
                                      draftFilters.add(option);
                                    } else {
                                      draftFilters.remove(option);
                                    }
                                  });
                                },
                                activeColor: _deepBlue,
                                checkColor: Colors.white,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                title: Text(
                                  option,
                                  style: const TextStyle(
                                    color: Color(0xFF1D2450),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _deepBlue,
                                side: const BorderSide(color: _deepBlue),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setSheetState(draftFilters.clear);
                              },
                              child: const Text(
                                "Clear All",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _deepBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  selectedFilters
                                    ..clear()
                                    ..addAll(draftFilters);
                                });
                                Navigator.pop(sheetContext);
                              },
                              child: const Text(
                                "Apply",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateFromDrawer(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  late Future<Map<String, dynamic>> diseaseFuture;

  void _refreshSelfReports() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SelfReportStore.instance.removeListener(_refreshSelfReports);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SelfReportStore.instance.addListener(_refreshSelfReports);
    diseaseFuture = HealthPhApiService(
      baseUrl: 'http://10.0.2.2:8000',
    ).fetchDiseasePoints();
  }

  final Map<String, LatLng> regionCenters = {
    "NCR": LatLng(14.5995, 120.9842),
    "I": LatLng(16.0832, 120.6199),
    "II": LatLng(17.6132, 121.7270),
    "III": LatLng(15.4828, 120.7120),
    "IVA": LatLng(14.1008, 121.0794),
    "V": LatLng(13.6218, 123.1948),
    "VI": LatLng(11.0050, 122.5373),
    "VII": LatLng(10.3157, 123.8854),
    "VIII": LatLng(11.2433, 125.0046),
    "IX": LatLng(7.8383, 123.2967),
    "X": LatLng(8.4542, 124.6319),
    "XI": LatLng(7.1907, 125.4553),
    "XII": LatLng(6.2707, 124.6857),
    "XIII": LatLng(8.9475, 125.5406),
    "CAR": LatLng(16.4023, 120.5960),
    "BARMM": LatLng(7.2167, 124.2500),
  };

  @override //build()
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = Responsive.isTablet(context);
    final initialZoom = isTablet ? 6.16 : 5.5;
    final headerWidth = isTablet
        ? 390.0
        : (screenWidth - 148).clamp(180.0, 420.0).toDouble();
    final filterWidth = isTablet
        ? 390.0
        : (screenWidth - 98).clamp(220.0, 430.0).toDouble();
    final markerSize = isTablet ? 88.0 : 80.0;
    final pinIconSize = isTablet ? 50.0 : 44.0;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _pageBlue,
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Positioned.
          fill(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: philippinesCenter,
                initialZoom: initialZoom,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.healthphplus',
                ),
                MarkerLayer(
                  markers: filteredOutbreaks.map((outbreak) {
                    return Marker(
                      point: LatLng(outbreak["lat"], outbreak["lng"]),
                      width: markerSize,
                      height: markerSize,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (_) {
                              return OutbreakDetailsSheet(outbreak: outbreak);
                            },
                          );
                        },
                        child: Icon(
                          Icons.location_on,
                          color: outbreak['source'] == "selfReport"
                              ? AppTheme.info
                              : Colors.redAccent,
                          size: pinIconSize,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          Positioned(
            left: 16,
            top: safeTop + 12,
            child: MapControlButton(
              icon: Icons.menu,
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),

          Positioned(
            left: 72,
            top: safeTop + 12,
            child: SizedBox(
              width: headerWidth,
              child: _MapHeader(
                reportCount: filteredOutbreaks.length,
                filterSummary: filterSummary
              ),
            ),
          ),

          Positioned(
            left: 16,
            top: safeTop + 94,
            child: SizedBox(
              width: filterWidth,
              child: _FilterButton(
                summary: filterSummary,
                selectedCount: selectedFilters.length,
                onTap: _openDiseaseFilterSheet,
              ),
            ),
          ),

          // MAP CONTROLLERS
          Positioned(
            right: 12,
            top: safeTop + 12,
            child: Column(
              children: [
                MapControlButton(icon: Icons.add, onTap: zoomIn),
                const SizedBox(height: 8),
                MapControlButton(icon: Icons.remove, onTap: zoomOut),
                const SizedBox(height: 8),
                MapControlButton(icon: Icons.my_location, onTap: resetMapView),
              ],
            ),
          ),

          // DATE UPDATE LABEL
          Positioned(
            left: 12,
            bottom: safeBottom + 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                "Map data updates show latest reported outbreak activity.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 10,
                  height: 1.3,
                  fontWeight: FontWeight.bold,
                  color:AppTheme.text,
                ),
              )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/healthphplusbarlogo.png',
                    height: 50,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Disease Map",
                    style: TextStyle(
                      color: _navy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Respiratory outbreak monitoring",
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerNavTile(
              icon: Icons.home,
              label: "Home",
              onTap: () => _navigateFromDrawer(context, const MainPage()),
            ),
            _DrawerNavTile(
              icon: Icons.map,
              label: "Disease Map",
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerNavTile(
              icon: Icons.coronavirus,
              label: "Disease Watch",
              onTap: () =>
                  _navigateFromDrawer(context, const DiseaseWatchPage()),
            ),
            _DrawerNavTile(
              icon: Icons.article_outlined,
              label: "Health Literacy",
              onTap: () =>
                  _navigateFromDrawer(context, const HealthLiteracyPage()),
            ),
            _DrawerNavTile(
              icon: Icons.analytics,
              label: "Sentiment Pulse",
              onTap: () =>
                  _navigateFromDrawer(context, const SentimentPulsePage()),
            ),
            _DrawerNavTile(
              icon: Icons.assignment,
              label: "Data Collection",
              onTap: () =>
                  _navigateFromDrawer(context, const DataCollectionPage()),
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerNavTile(
              icon: Icons.settings,
              label: "Settings",
              onTap: () => _navigateFromDrawer(context, const SettingsPage()),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MapHeader extends StatelessWidget {
  final int reportCount;
  final String filterSummary;

  const _MapHeader({required this.reportCount, required this.filterSummary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('assets/images/healthphplusbarlogo.png', height: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Outbreak Map",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _MapPageState._navy,
                  ),
                ),
                Text(
                  "$reportCount active reports",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _MapPageState._deepBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  filterSummary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String summary;
  final int selectedCount;
  final VoidCallback onTap;

  const _FilterButton({
    required this.summary,
    required this.selectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 5,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.checklist, color: _MapPageState._deepBlue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Select Diseases / Symptoms",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _MapPageState._navy,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      summary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              selectedCount > 0
                  ? Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _MapPageState._yellow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        "$selectedCount",
                        style: const TextStyle(
                          color: _MapPageState._navy,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.keyboard_arrow_up,
                      color: _MapPageState._deepBlue,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _DrawerNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: _MapPageState._lightPurple,
      leading: Icon(
        icon,
        color: isSelected ? _MapPageState._deepBlue : Colors.black54,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? _MapPageState._navy : const Color(0xFF1D2450),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}

class MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MapControlButton({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class OutbreakDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> outbreak;

  const OutbreakDetailsSheet({super.key, required this.outbreak});

  @override
  Widget build(BuildContext context) {
    final tags = outbreak["tags"] as List<String>;

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            outbreak["disease"],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF243B8F),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            outbreak["name"],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Text(
            outbreak["category"],
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 8),

          Text(
            "${outbreak["reports"]} reports",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),

          Text(outbreak["updated"], style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 12),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) {
              return Chip(
                label: Text(tag, style: const TextStyle(fontSize: 11)),
                backgroundColor: const Color(0xFFDDE6FF),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
