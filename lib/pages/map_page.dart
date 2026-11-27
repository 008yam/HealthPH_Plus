import '../localization/app_translations.dart';
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
import '../services/api_config.dart';
import '../services/region_boundary_service.dart';
import '../theme/app_theme.dart';
import '../models/surveillance_pin.dart';
import '../theme/responsive.dart';
import '../widgets/floating_navbar.dart';
export '../widgets/map/map_outbreak_details_sheet.dart';
import '../widgets/map/map_control_button.dart';
import '../widgets/map/map_summary_overlays.dart';
import '../widgets/map/map_navigation_drawer.dart';
import '../widgets/map/map_filter_sheet.dart';
import '../widgets/map/map_pin_sheet.dart';

class MapPage extends StatefulWidget {
  final HealthPhApiService? service;
  const MapPage({super.key, this.service});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController mapController = MapController();
  final LatLng philippinesCenter = const LatLng(12.8797, 121.7740);
  late final HealthPhApiService _service;
  List<SurveillancePin> _pins = [];
  bool _loading = true;
  bool _failed = false;
  String? _errorDetail;
  int _requestId = 0;
  int _days = 7;
  String _region = 'all';
  String _disease = 'all';

  String get filterSummary =>
      '${context.tr(mapTimelineOptions[_days]!)} · $_region · $_disease';

  RegionBoundary? _selectedBoundary;
  int _boundaryRequest = 0;

  Future<void> _focusRegion() async {
    final request = ++_boundaryRequest;
    final region = _region;
    setState(() => _selectedBoundary = null);
    if (region == 'all') {
      resetMapView();
      return;
    }
    try {
      final boundaries = await RegionBoundaryService.load();
      if (!mounted || request != _boundaryRequest) return;
      final boundary = boundaries[region];
      if (boundary == null || boundary.outlinePoints.isEmpty) {
        throw const FormatException('Region boundary unavailable');
      }
      setState(() => _selectedBoundary = boundary);
      final size = MediaQuery.sizeOf(context);
      mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(boundary.outlinePoints),
          padding: EdgeInsets.fromLTRB(
            32,
            size.height * 0.25,
            32,
            size.height * 0.20,
          ),
        ),
      );
    } catch (_) {
      if (!mounted || request != _boundaryRequest) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load the region boundary.')),
      );
    }
  }

  Future<void> _loadPins() async {
    final request = ++_requestId;
    setState(() {
      _loading = true;
      _failed = false;
      _errorDetail = null;
      _pins = [];
    });
    try {
      final pins = await _service.fetchSurveillanceMapPins(
        days: _days,
        region: _region,
        disease: _disease,
      );
      if (!mounted || request != _requestId) return;
      setState(() {
        _pins = pins;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _failed = true;
        _errorDetail = error is SurveillanceMapException
            ? error.message
            : error is FormatException
            ? 'The backend returned an incompatible surveillance response.'
            : 'The map request failed. Check the backend connection.';
        _loading = false;
      });
    }
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

  Future<void> _openDiseaseFilterSheet() async {
    final selection = await showMapFilterSheet(
      context: context,
      initialSelection: MapFilterSelection(
        days: _days,
        region: _region,
        disease: _disease,
      ),
    );

    if (!mounted || selection == null) return;

    setState(() {
      _days = selection.days;
      _region = selection.region;
      _disease = selection.disease;
    });

    _loadPins();
    _focusRegion();
  }

  void _navigateFromDrawer(BuildContext context, Widget page) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? HealthPhApiService(baseUrl: ApiConfig.baseUrl);
    _loadPins();
  }

  Future<void> _openPin(SurveillancePin pin) async {
    mapController.move(
      LatLng(pin.latitude, pin.longitude),
      mapController.camera.zoom.clamp(7.5, 9.0).toDouble(),
    );

    await showSurveillancePinSheet(context: context, pin: pin);
  }

  @override //build()
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = Responsive.isTablet(context);
    final isLandscapePhone = Responsive.isLandscapePhone(context);
    final initialZoom = isTablet ? 6.16 : 5.5;
    final headerWidth = isTablet
        ? 390.0
        : (screenWidth - (isLandscapePhone ? 164 : 148))
              .clamp(180.0, isLandscapePhone ? 360.0 : 420.0)
              .toDouble();
    final filterWidth = isTablet
        ? 390.0
        : (screenWidth - (isLandscapePhone ? 112 : 98))
              .clamp(220.0, isLandscapePhone ? 360.0 : 430.0)
              .toDouble();
    final markerSize = isTablet ? 88.0 : (isLandscapePhone ? 66.0 : 80.0);
    final pinIconSize = isTablet ? 50.0 : (isLandscapePhone ? 38.0 : 44.0);
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      backgroundColor: Colors.transparent,
      drawer: MapNavigationDrawer(
        onHome: () => _navigateFromDrawer(context, const MainPage()),
        onMap: () => Navigator.pop(context),
        onDiseaseWatch: () =>
            _navigateFromDrawer(context, const DiseaseWatchPage()),
        onHealthLiteracy: () =>
            _navigateFromDrawer(context, const HealthLiteracyPage()),
        onSentimentPulse: () =>
            _navigateFromDrawer(context, const SentimentPulsePage()),
        onDataCollection: () =>
            _navigateFromDrawer(context, const DataCollectionPage()),
        onProfile: () => _navigateFromDrawer(context, const SettingsPage()),
      ),
      body: Stack(
        children: [
          Positioned.fill(
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
                if (_selectedBoundary != null)
                  IgnorePointer(
                    child: PolygonLayer(
                      polygons: [
                        for (final rings in _selectedBoundary!.polygons)
                          Polygon(
                            points: rings.first,
                            holePointsList: rings.skip(1).toList(),
                            color: const Color(0x2231459B),
                            borderColor: const Color(0xFF31459B),
                            borderStrokeWidth: 2,
                          ),
                      ],
                    ),
                  ),
                MarkerLayer(
                  markers: _pins.map((pin) {
                    return Marker(
                      key: ValueKey(pin.id),
                      point: LatLng(pin.latitude, pin.longitude),
                      width: markerSize,
                      height: markerSize,
                      child: GestureDetector(
                        onTap: () => _openPin(pin),
                        child: Icon(
                          Icons.location_on,
                          color: AppTheme.info,
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
              child: MapHeader(
                reportCount: _pins.fold<int>(
                  0,
                  (sum, pin) => sum + pin.processedEntryCount,
                ),
                filterSummary: filterSummary,
              ),
            ),
          ),

          Positioned(
            left: 16,
            top: safeTop + (isLandscapePhone ? 78 : 94),
            child: SizedBox(
              width: filterWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MapFilterButton(
                    summary: filterSummary,
                    selectedCount:
                        (_days != 7 ? 1 : 0) +
                        (_region != 'all' ? 1 : 0) +
                        (_disease != 'all' ? 1 : 0),
                    onTap: _openDiseaseFilterSheet,
                  ),
                  const SizedBox(height: 8),
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _loading
                                ? const LinearProgressIndicator()
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr(
                                          _failed
                                              ? 'Unable to load disease signals.'
                                              : _pins.isEmpty
                                              ? 'No processed disease signals for these filters.'
                                              : 'Processed disease signals',
                                        ),
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      if (_failed && _errorDetail != null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            context.tr(_errorDetail!),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                          ),
                          IconButton(
                            tooltip: context.tr(_failed ? 'Retry' : 'Refresh'),
                            onPressed: _loading ? null : _loadPins,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
        ],
      ),
      bottomNavigationBar: const FloatingNavBar(selectedIndex: 1),
    );
  }
}
