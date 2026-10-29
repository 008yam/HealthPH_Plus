import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../localization/app_translations.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherWidget extends StatefulWidget {
  final bool compact;
  final String region;
  final ValueChanged<String>? onRegionChanged;
  final WeatherService? service;
  final bool lockRegion;
  final bool embedded;
  const WeatherWidget({
    super.key,
    this.compact = false,
    this.region = 'NCR',
    this.onRegionChanged,
    this.service,
    this.lockRegion = false,
    this.embedded = false,
  });
  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget>
    with WidgetsBindingObserver {
  late final WeatherService _service;
  List<Map<String, String>> _locations = [];
  String? _selected;
  bool _catalogBusy = true, _catalogError = false;
  bool _weatherBusy = false, _airBusy = false;
  bool _weatherError = false, _airError = false;
  WeatherModel? _weather, _air;
  int _weatherRequest = 0, _airRequest = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? WeatherService();
    WidgetsBinding.instance.addObserver(this);
    _loadLocations();
    _startTimer();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _catalogBusy = true;
      _catalogError = false;
    });
    try {
      final locations = await _service.getLocations();
      if (!mounted) return;
      final desired = _selected ?? widget.region;
      if (widget.lockRegion &&
          !locations.any((location) => location['code'] == desired)) {
        throw const FormatException(
          'Selected pin region is unavailable in the weather catalog',
        );
      }
      setState(() {
        _locations = locations;
        _selected = locations.any((r) => r['code'] == desired)
            ? desired
            : locations.first['code'];
        _catalogBusy = false;
      });
      widget.onRegionChanged?.call(_selected!);
      _refresh();
    } catch (_) {
      if (mounted) {
        setState(() {
          _catalogBusy = false;
          _catalogError = true;
        });
      }
    }
  }

  Future<void> _loadReading(bool air) async {
    final region = _selected;
    if (region == null) return;
    final id = air ? ++_airRequest : ++_weatherRequest;
    setState(() {
      if (air) {
        _airBusy = true;
        _airError = false;
        _air = null;
      } else {
        _weatherBusy = true;
        _weatherError = false;
        _weather = null;
      }
    });
    try {
      final data = await (air
          ? _service.getAirQuality(region: region)
          : _service.getWeather(region: region));
      if (!mounted ||
          region != _selected ||
          id != (air ? _airRequest : _weatherRequest)) {
        return;
      }
      if (data.region != region) throw const FormatException('Region mismatch');
      setState(() {
        if (air) {
          _air = data;
          _airBusy = false;
        } else {
          _weather = data;
          _weatherBusy = false;
        }
      });
    } catch (_) {
      if (!mounted ||
          region != _selected ||
          id != (air ? _airRequest : _weatherRequest)) {
        return;
      }
      setState(() {
        if (air) {
          _airBusy = false;
          _airError = true;
        } else {
          _weatherBusy = false;
          _weatherError = true;
        }
      });
    }
  }

  void _refresh() {
    if (!mounted || _selected == null) return;
    _loadReading(false);
    _loadReading(true);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 10), (_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  @override
  void didUpdateWidget(covariant WeatherWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.region != oldWidget.region &&
        _locations.any((r) => r['code'] == widget.region)) {
      _selected = widget.region;
      _refresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  String get _unavailable => context.tr('Unavailable');
  String _number(double? value, [String unit = '']) => value == null
      ? _unavailable
      : '${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)}$unit';
  String _time(WeatherModel? value) => value == null || value.dataTime.isEmpty
      ? _unavailable
      : '${value.dataTime.replaceFirst('T', ' ')} ${value.timezone}';

  String _condition(int? code) {
    const names = {
      0: 'Clear sky',
      1: 'Mainly clear',
      2: 'Partly cloudy',
      3: 'Overcast',
      45: 'Fog',
      48: 'Depositing rime fog',
      51: 'Light drizzle',
      53: 'Moderate drizzle',
      55: 'Dense drizzle',
      56: 'Light freezing drizzle',
      57: 'Dense freezing drizzle',
      61: 'Slight rain',
      63: 'Moderate rain',
      65: 'Heavy rain',
      66: 'Light freezing rain',
      67: 'Heavy freezing rain',
      71: 'Slight snowfall',
      73: 'Moderate snowfall',
      75: 'Heavy snowfall',
      77: 'Snow grains',
      80: 'Slight rain showers',
      81: 'Moderate rain showers',
      82: 'Violent rain showers',
      85: 'Slight snow showers',
      86: 'Heavy snow showers',
      95: 'Thunderstorm',
      96: 'Thunderstorm with slight hail',
      97: 'Heavy thunderstorm',
      99: 'Thunderstorm with heavy hail',
    };
    return context.tr(names[code] ?? 'Unavailable');
  }

  String _wind() {
    final speed = _weather?.windSpeed;
    if (speed == null) return _unavailable;
    if (speed == 0) return context.tr('Calm');
    final direction = _weather?.windDirection;
    const compass = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final suffix = direction == null
        ? ''
        : ' · ${compass[((direction % 360) / 45).round() % 8]}';
    return '${_number(speed, ' km/h')}$suffix';
  }

  Widget _metric(String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: LayoutBuilder(
      builder: (context, bounds) {
        final narrow =
            bounds.maxWidth < 260 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final caption = Text(
          context.tr(label),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        );
        final reading = Text(
          value,
          textAlign: narrow ? TextAlign.left : TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w700),
        );
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [caption, const SizedBox(height: 4), reading],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: caption),
            const SizedBox(width: 12),
            Expanded(child: reading),
          ],
        );
      },
    ),
  );

  Widget _error(bool air) => Row(
    children: [
      Expanded(
        child: Text(
          context.tr(air ? 'Air quality unavailable' : 'Weather unavailable'),
        ),
      ),
      IconButton(
        tooltip: context.tr('Retry'),
        icon: const Icon(Icons.refresh),
        onPressed: () => _loadReading(air),
      ),
    ],
  );

  Future<void> _openSource(String address) async {
    var opened = false;
    try {
      opened = await launchUrl(
        Uri.parse(address),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('Unable to open source'))),
      );
    }
  }

  void _showInfo() => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.tr('Environmental Data')),
      content: SingleChildScrollView(
        child: Text(
          context.tr(
            'Reference-city model estimates, not regional averages or personal sensor readings. '
            'Air quality uses the US AQI scale and an approximately 45 km model. '
            'Heat index assumes shade and light wind. Wind direction indicates where wind comes from. '
            'Weather and air quality can have different timestamps.',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('Close')),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final city = _locations
        .where((r) => r['code'] == _selected)
        .map((r) => r['city'])
        .firstOrNull;
    final seconds = _weather?.intervalSeconds;
    final interval = seconds == null || seconds <= 0
        ? ''
        : seconds % 60 == 0
        ? ' (${seconds ~/ 60} min)'
        : ' ($seconds s)';
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: widget.embedded
            ? BorderSide.none
            : BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          child: SingleChildScrollView(
            primary: widget.embedded ? false : null,
            physics: widget.embedded
                ? const NeverScrollableScrollPhysics()
                : null,
            padding: EdgeInsets.all(widget.embedded ? 16 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('Environmental Data'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: context.tr('About environmental data'),
                      onPressed: _showInfo,
                      icon: const Icon(Icons.info_outline),
                    ),
                  ],
                ),
                if (_catalogBusy)
                  const LinearProgressIndicator()
                else if (_catalogError)
                  Row(
                    children: [
                      Expanded(
                        child: Text(context.tr('Unable to load regions')),
                      ),
                      IconButton(
                        tooltip: context.tr('Retry'),
                        onPressed: _loadLocations,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  )
                else ...[
                  if (!widget.lockRegion)
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.tr('Region'),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selected,
                          isExpanded: true,
                          itemHeight: null,
                          selectedItemBuilder: (context) => _locations
                              .map(
                                (r) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Tooltip(
                                    message: r['name']!,
                                    child: Text(
                                      '${r['code']} · ${r['name']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          items: _locations
                              .map(
                                (r) => DropdownMenuItem(
                                  value: r['code'],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text('${r['code']} · ${r['name']}'),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: widget.lockRegion
                              ? null
                              : (value) {
                                  if (value == null || value == _selected) {
                                    return;
                                  }
                                  setState(() => _selected = value);
                                  widget.onRegionChanged?.call(value);
                                  _refresh();
                                },
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    city ?? _unavailable,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    context.tr('Reference-city model estimates'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_weatherBusy)
                    const LinearProgressIndicator()
                  else if (_weatherError)
                    _error(false)
                  else ...[
                    _metric('Conditions', _condition(_weather?.weatherCode)),
                    _metric(
                      'Temp / humidity',
                      '${_number(_weather?.temperature, ' °C')} / ${_number(_weather?.humidity, '%')}',
                    ),
                    _metric(
                      'Estimated Heat Index',
                      _number(_weather?.heatIndex, ' °C'),
                    ),
                    _metric('Wind', _wind()),
                    _metric(
                      '${context.tr('Precipitation')}$interval',
                      _number(_weather?.precipitation, ' mm'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (_airBusy)
                    const LinearProgressIndicator()
                  else if (_airError)
                    _error(true)
                  else ...[
                    _metric('US AQI', _number(_air?.aqi)),
                    _metric('PM2.5', _number(_air?.pm25, ' µg/m³')),
                  ],
                  const SizedBox(height: 12),
                  Text('${context.tr('Weather')}: ${_time(_weather)}'),
                  const SizedBox(height: 6),
                  Text('${context.tr('Air quality')}: ${_time(_air)}'),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('${context.tr('Sources')}: '),
                      TextButton(
                        onPressed: () => _openSource('https://open-meteo.com/'),
                        child: const Text('Open-Meteo'),
                      ),
                      TextButton(
                        onPressed: () =>
                            _openSource('https://atmosphere.copernicus.eu/'),
                        child: const Text('CAMS'),
                      ),
                      IconButton(
                        tooltip: context.tr('Refresh'),
                        icon: const Icon(Icons.refresh),
                        onPressed: _weatherBusy || _airBusy ? null : _refresh,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
