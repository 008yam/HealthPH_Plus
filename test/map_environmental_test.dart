import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/models/weather_model.dart';
import 'package:healthphplus/pages/map_page.dart';
import 'package:healthphplus/services/weather_service.dart';
import 'package:healthphplus/theme/app_theme.dart';
import 'package:healthphplus/widgets/map_weather_menu.dart';
import 'package:healthphplus/widgets/weather_widget.dart';

class FakeWeatherService extends WeatherService {
  final List<String> calls = [];
  bool failAir = false;
  Completer<WeatherModel>? pendingNcr;

  WeatherModel reading(String region) => WeatherModel(
    city: region == 'NCR' ? 'Manila' : 'Cagayan de Oro',
    region: region,
    dataTime: '2026-10-28T09:15',
    timezone: 'Asia/Manila',
    attribution: 'Open-Meteo',
    temperature: 29,
    humidity: 72,
    windSpeed: 0,
    precipitation: 0,
    intervalSeconds: 900,
    heatIndex: 33.1,
    weatherCode: 2,
    aqi: 0,
    pm25: null,
  );

  @override
  Future<List<Map<String, String>>> getLocations() async => [
    {'code': 'NCR', 'name': 'National Capital Region', 'city': 'Manila'},
    {'code': 'X', 'name': 'Northern Mindanao', 'city': 'Cagayan de Oro'},
  ];
  @override
  Future<WeatherModel> getWeather({String region = 'NCR'}) async {
    calls.add(region);
    if (region == 'NCR' && pendingNcr != null) return pendingNcr!.future;
    return reading(region);
  }

  @override
  Future<WeatherModel> getAirQuality({String region = 'NCR'}) async {
    if (failAir) throw Exception('Offline');
    return reading(region);
  }
}

void main() {
  Future<void> setup(
    WidgetTester tester,
    Widget child, {
    bool dark = false,
    Size size = const Size(420, 900),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> selectX(WidgetTester tester) async {
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('X · Northern Mindanao').last);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'starts collapsed, preserves region when reopened, and leaves map tappable',
    (tester) async {
      final service = FakeWeatherService();
      var taps = 0;
      await setup(
        tester,
        Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => taps++,
                child: const ColoredBox(color: Colors.green),
              ),
            ),
            Positioned.fill(
              child: MapWeatherMenu(reservedTop: 190, service: service),
            ),
          ],
        ),
      );
      expect(service.calls, isEmpty);
      await tester.tapAt(const Offset(20, 200));
      expect(taps, 1);
      final toggle = find.byKey(const ValueKey('weather-menu-toggle'));
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      await selectX(tester);
      expect(find.text('Cagayan de Oro'), findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byType(WeatherWidget), findsNothing);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.text('Cagayan de Oro'), findsOneWidget);
      expect(service.calls.last, 'X');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ignores previous-region replies and isolates air failure', (
    tester,
  ) async {
    final service = FakeWeatherService()
      ..pendingNcr = Completer<WeatherModel>()
      ..failAir = true;
    await setup(tester, WeatherWidget(service: service));
    await selectX(tester);
    service.pendingNcr!.complete(service.reading('NCR'));
    await tester.pumpAndSettle();
    expect(find.text('Cagayan de Oro'), findsOneWidget);
    expect(find.text('Manila'), findsNothing);
    expect(find.text('Partly cloudy'), findsOneWidget);
    expect(find.text('Air quality unavailable'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('landscape large text uses dismissible sheet without overflow', (
    tester,
  ) async {
    await setup(
      tester,
      MapWeatherMenu(reservedTop: 180, service: FakeWeatherService()),
      size: const Size(850, 390),
      scale: 2,
      dark: true,
    );
    await tester.tap(find.byKey(const ValueKey('weather-menu-toggle')));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets(
    'dark pin sheet uses paired chip colors and handles absent tags',
    (tester) async {
      await setup(
        tester,
        const OutbreakDetailsSheet(
          outbreak: {
            'disease': 'Cough',
            'name': 'Manila',
            'reports': 1,
            'tags': ['Fever'],
          },
        ),
        dark: true,
      );
      final chip = tester.widget<Chip>(find.byType(Chip));
      final colors = AppTheme.darkTheme.colorScheme;
      expect(chip.backgroundColor, colors.secondaryContainer);
      expect((chip.label as Text).style!.color, colors.onSecondaryContainer);
      expect(tester.takeException(), isNull);
    },
  );

  test('weather parsing preserves zero, null, and heat-index metadata', () {
    final data = WeatherModel.fromJson({
      'region': 'NCR',
      'reference_location': {'name': 'Manila'},
      'attribution': {'label': 'Open-Meteo'},
      'weather': {
        'temperature': null,
        'precipitation': 0,
        'estimated_heat_index': 33.1,
        'interval_seconds': 900,
        'weather_code': 2,
      },
    }, airQuality: false);
    expect(data.temperature, isNull);
    expect(data.precipitation, 0);
    expect(data.heatIndex, 33.1);
    expect(data.intervalSeconds, 900);
  });
}
