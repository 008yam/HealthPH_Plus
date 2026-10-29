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
import '../theme/app_theme.dart';
import '../models/surveillance_pin.dart';
import '../widgets/surveillance_pin_details.dart';
import '../theme/responsive.dart';
import '../widgets/weather_widget.dart';
import '../widgets/floating_navbar.dart';
import '../services/region_boundary_service.dart';

class MapPage extends StatefulWidget {
  final HealthPhApiService? service;
  const MapPage({super.key, this.service});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const Color _navy = Color(0xFF243B8F);
  static const Color _deepBlue = Color(0xFF31459B);
  static const Color _lightPurple = Color(0xFFDDE6FF);
  static const Color _yellow = Color(0xFFFFD84D);

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

  static const timelineOptions = {
    1: 'Last 24 hours',
    7: 'Last 7 days',
    30: 'Last 30 days',
  };

  String get filterSummary =>
      '${context.tr(timelineOptions[_days]!)} · $_region · $_disease';

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

  void _openDiseaseFilterSheet() {
    var days = _days;
    var region = _region;
    var disease = _disease;
    final form = GlobalKey<FormState>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('Disease-signal filters'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: const ValueKey('surveillance-timeline'),
                    initialValue: days,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Timeline'),
                    ),
                    items: timelineOptions.entries
                        .map(
                          (entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(context.tr(entry.value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => days = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: region,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Region'),
                    ),
                    items:
                        [
                              'all',
                              'NCR',
                              'I',
                              'II',
                              'III',
                              'IVA',
                              'IVB',
                              'V',
                              'VI',
                              'VII',
                              'VIII',
                              'IX',
                              'X',
                              'XI',
                              'XII',
                              'XIII',
                              'CAR',
                              'BARMM',
                            ]
                            .map(
                              (code) => DropdownMenuItem(
                                value: code,
                                child: Text(
                                  code == 'all'
                                      ? context.tr('All regions')
                                      : code,
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) => update(() => region = value!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: disease,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.tr('Disease'),
                    ),
                    items: ['all', ...SurveillancePin.diseases]
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(
                              code == 'all' ? context.tr('All diseases') : code,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => update(() => disease = value!),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      if (!form.currentState!.validate()) return;
                      form.currentState!.save();
                      setState(() {
                        _days = days;
                        _region = region;
                        _disease = disease;
                      });
                      Navigator.pop(sheetContext);
                      _loadPins();
                      _focusRegion();
                    },
                    child: Text(context.tr('Apply')),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

  void _openPin(SurveillancePin pin) {
    mapController.move(
      LatLng(pin.latitude, pin.longitude),
      mapController.camera.zoom.clamp(7.5, 9.0).toDouble(),
    );
    final region = pin.region?.trim();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      barrierColor: Colors.black.withValues(alpha: 0.12),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.82,
        minChildSize: 0.40,
        maxChildSize: 0.94,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: EdgeInsets.only(
            bottom: 16 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            SurveillancePinDetails(
              pin: pin,
              embedded: true,
              onClose: () => Navigator.pop(sheetContext),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            if (region != null && region.isNotEmpty)
              WeatherWidget(
                key: ValueKey('pin-weather-${pin.id}'),
                region: region,
                lockRegion: true,
                embedded: true,
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.tr(
                    'Weather unavailable: this pin has no region code.',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      drawer: _buildDrawer(context),
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
              child: _MapHeader(
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
                  _FilterButton(
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

  Widget _buildDrawer(BuildContext context) {
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return Drawer(
      width: isLandscapePhone ? 320 : null,
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                isLandscapePhone ? 10 : 14,
                18,
                isLandscapePhone ? 10 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/healthphplusbarlogo.png',
                    height: isLandscapePhone ? 36 : 50,
                  ),
                  SizedBox(height: isLandscapePhone ? 6 : 10),
                  Text(
                    context.tr("Disease Map"),
                    style: TextStyle(
                      color: _navy,
                      fontSize: isLandscapePhone ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    context.tr("Respiratory outbreak monitoring"),
                    style: TextStyle(
                      color: _deepBlue,
                      fontSize: isLandscapePhone ? 11 : 12,
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
            const Divider(height: 1),
            _DrawerNavTile(
              icon: Icons.person_outline,
              label: "Profile",
              onTap: () => _navigateFromDrawer(context, const SettingsPage()),
            ),
            SizedBox(height: isLandscapePhone ? 6 : 8),
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
                Text(
                  context.tr('Disease-signal Map'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _MapPageState._navy,
                  ),
                ),
                Text(
                  context.tr(
                    "{reportCount} processed entries",
                    parameters: {"reportCount": reportCount},
                  ),
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
                    Text(
                      context.tr('Filter disease signals'),
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
    final isLandscapePhone = Responsive.isLandscapePhone(context);

    return ListTile(
      dense: isLandscapePhone,
      visualDensity: isLandscapePhone
          ? const VisualDensity(horizontal: -2, vertical: -3)
          : VisualDensity.standard,
      minLeadingWidth: isLandscapePhone ? 28 : null,
      selected: isSelected,
      selectedTileColor: _MapPageState._lightPurple,
      leading: Icon(
        icon,
        size: isLandscapePhone ? 22 : 24,
        color: isSelected ? _MapPageState._deepBlue : Colors.black54,
      ),
      title: Text(
        context.tr(label),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isSelected ? _MapPageState._navy : const Color(0xFF1D2450),
          fontSize: isLandscapePhone ? 14 : 16,
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
    final size = Responsive.mapControlSize(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: AppTheme.primary, size: size * 0.52),
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
    final colors = Theme.of(context).colorScheme;
    final rawTags = outbreak['tags'];
    final tags = rawTags is List
        ? rawTags.whereType<String>().toList()
        : <String>[];
    String value(String key) => outbreak[key]?.toString() ?? '';
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: DefaultTextStyle(
          style: TextStyle(color: colors.onSurface, fontSize: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.tr(value('disease')),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.tr('Close'),
                    color: colors.onSurface,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value('name'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                context.tr(value('category')),
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr(
                  '{count} reports',
                  parameters: {'count': outbreak['reports'] ?? 0},
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                value('updated'),
                style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
              ),
              if (value('pinAccuracy').isNotEmpty)
                Text(
                  context.tr(value('pinAccuracy')),
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text(
                          context.tr(tag),
                          style: TextStyle(color: colors.onSecondaryContainer),
                        ),
                        backgroundColor: colors.secondaryContainer,
                        side: BorderSide(color: colors.outlineVariant),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
