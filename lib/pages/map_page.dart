import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:healthphplus/main_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController mapController = MapController();

  String selectedTag = "All";

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
      "tags": ["AURI", "Cough", "Fever", "Sore throat"],
    },
    {
      "name": "Laguna Province",
      "disease": "Pneumonia",
      "category": "Lower Respiratory",
      "reports": 28,
      "updated": "Updated: May 31, 2026",
      "lat": 14.1709,
      "lng": 121.2446,
      "tags": ["Pneumonia", "Breathing difficulty", "Fever"],
    },
    {
      "name": "Bulacan Province",
      "disease": "Tuberculosis",
      "category": "Respiratory",
      "reports": 15,
      "updated": "Updated: May 30, 2026",
      "lat": 14.7943,
      "lng": 120.8799,
      "tags": ["Tuberculosis", "Cough", "Chest pain"],
    },
  ];

  List<String> get allTags {
    final tags = outbreaks
        .expand((item) => item["tags"] as List<String>)
        .toSet()
        .toList();
    return ["All", ...tags];
  }

  List<Map<String, dynamic>> get filteredOutbreaks {
    if (selectedTag == "All") return outbreaks;

    return outbreaks.where((outbreak) {
      final tags = outbreak["tags"] as List<String>;
      return tags.contains(selectedTag);
    }).toList();
  }

  void resetMapView() {
    mapController.move(philippinesCenter, 5.5);
  }

  void zoomIn() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom + 1);
  }

  void zoomOut() {
    final currentZoom = mapController.camera.zoom;
    mapController.move(mapController.camera.center, currentZoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B4C98),
      body: Column(
        children: [
          // HEADER
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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                        );
                      },
                      child: const Text("Back"),
                    ),

                    const SizedBox(height: 8),

                    Image.asset(
                      'assets/images/healthphplusbarlogo.png',
                      height: 55,
                    ),

                    const Text(
                      "Outbreak Map",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF243B8F),
                      ),
                    ),

                    Text(
                      "${filteredOutbreaks.length} active map reports",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF243B8F),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // TAG FILTERS
          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: allTags.length,
              itemBuilder: (context, index) {
                final tag = allTags[index];
                final isSelected = selectedTag == tag;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    selectedColor: const Color(0xFF31459B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) {
                      setState(() {
                        selectedTag = tag;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // MAP
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: philippinesCenter,
                      initialZoom: 5.5,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.healthphplus',
                      ),

                      MarkerLayer(
                        markers: filteredOutbreaks.map((outbreak) {
                          return Marker(
                            point: LatLng(outbreak["lat"], outbreak["lng"]),
                            width: 80,
                            height: 80,
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
                                    return OutbreakDetailsSheet(
                                      outbreak: outbreak,
                                    );
                                  },
                                );
                              },
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.redAccent,
                                size: 44,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),

                  // MAP CONTROLLERS
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Column(
                      children: [
                        MapControlButton(icon: Icons.add, onTap: zoomIn),
                        const SizedBox(height: 8),
                        MapControlButton(icon: Icons.remove, onTap: zoomOut),
                        const SizedBox(height: 8),
                        MapControlButton(
                          icon: Icons.my_location,
                          onTap: resetMapView,
                        ),
                      ],
                    ),
                  ),

                  // DATE UPDATE LABEL
                  Positioned(
                    left: 12,
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      child: const Text(
                        "Map data updates show latest reported outbreak activity.",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          width: 42,
          height: 42,
          child: Icon(icon, color: const Color(0xFF31459B)),
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
