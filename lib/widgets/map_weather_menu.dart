import 'package:flutter/material.dart';
import '../localization/app_translations.dart';
import '../services/weather_service.dart';
import 'weather_widget.dart';

/// Place inside a Positioned.fill in the map Stack. Only the panel receives taps.
class MapWeatherMenu extends StatefulWidget {
  final double reservedTop;
  final WeatherService? service;
  const MapWeatherMenu({super.key, required this.reservedTop, this.service});

  @override
  State<MapWeatherMenu> createState() => _MapWeatherMenuState();
}

class _MapWeatherMenuState extends State<MapWeatherMenu> {
  bool _expanded = false;
  String _region = 'NCR';

  Widget _content() => WeatherWidget(
    region: _region,
    service: widget.service,
    onRegionChanged: (region) => _region = region,
  );

  void _openSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.85,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                tooltip: context.tr('Close'),
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final inset = MediaQuery.paddingOf(context);
    return LayoutBuilder(
      builder: (context, bounds) {
        // Scaffold.extendBody exposes the floating navbar height as bottom padding.
        final bottom = inset.bottom + 12;
        final available = bounds.maxHeight - widget.reservedTop - bottom;
        final shortScreen =
            available < 260 || MediaQuery.textScalerOf(context).scale(14) > 24;
        final expanded = _expanded && !shortScreen;
        final width = (bounds.maxWidth - inset.horizontal - 24)
            .clamp(0.0, 360.0)
            .toDouble();
        final header = ListTile(
          key: const ValueKey('weather-menu-toggle'),
          leading: Icon(Icons.cloud_outlined, color: colors.primary),
          title: Text(
            context.tr('Environmental Data'),
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            expanded ? Icons.expand_more : Icons.expand_less,
            color: colors.onSurface,
          ),
          onTap: () {
            if (shortScreen) {
              _openSheet();
            } else {
              setState(() => _expanded = !_expanded);
            }
          },
        );
        return Padding(
          padding: EdgeInsets.only(right: inset.right + 12, bottom: bottom),
          child: Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: width,
              height: expanded
                  ? available.clamp(260.0, 540.0).toDouble()
                  : null,
              child: Material(
                color: colors.surface,
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                clipBehavior: Clip.antiAlias,
                child: expanded
                    ? Column(
                        children: [
                          header,
                          Expanded(child: _content()),
                        ],
                      )
                    : header,
              ),
            ),
          ),
        );
      },
    );
  }
}
