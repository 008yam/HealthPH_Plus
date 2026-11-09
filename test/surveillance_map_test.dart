import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthphplus/services/healthph_api_services.dart';
import 'package:healthphplus/models/surveillance_pin.dart';
import 'package:healthphplus/pages/map_page.dart';
import 'package:healthphplus/widgets/surveillance_pin_details.dart';
import 'package:flutter_map/flutter_map.dart';

Map<String, dynamic> fixture() => {
  'id': 'aggregate-NCR',
  'latitude': 14.6,
  'longitude': 120.98,
  'diseaseCodes': ['TB', 'PN'],
  'diseaseCounts': {'TB': 2, 'PN': 2},
  'processedEntryCount': 3,
};

void main() {
  for (final preset in {
    1: 'Last 24 hours',
    7: 'Last 7 days',
    30: 'Last 30 days',
  }.entries) {
    testWidgets('timeline ${preset.value} sends ${preset.key} days', (
      tester,
    ) async {
      final requests = <Uri>[];
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          requests.add(request.url);
          return http.Response('{"items":[]}', 200);
        }),
      );
      await tester.pumpWidget(MaterialApp(home: MapPage(service: service)));
      await tester.pumpAndSettle();
      expect(requests.last.queryParameters['days'], '7');
      await tester.tap(find.text('Filter disease signals'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('surveillance-timeline')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(preset.value).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(requests.last.queryParameters, {
        'days': '${preset.key}',
        'region': 'all',
        'disease': 'all',
      });
      expect(find.text('${preset.value} · all · all'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'missing endpoint displays HTTP 404 separately from empty results',
    (tester) async {
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient(
          (_) async => http.Response('{"detail":"Not Found"}', 404),
        ),
      );
      await tester.pumpWidget(MaterialApp(home: MapPage(service: service)));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Surveillance endpoint not found (HTTP 404). Check the backend deployment.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('No processed disease signals for these filters.'),
        findsNothing,
      );
    },
  );

  testWidgets('renders only server pins and opens their breakdown', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = HealthPhApiService(
      baseUrl: 'http://example.test',
      client: MockClient((request) async {
        expect(request.url.queryParameters, {
          'days': '7',
          'region': 'all',
          'disease': 'all',
        });
        return http.Response(
          jsonEncode({
            'items': [fixture()],
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(MaterialApp(home: MapPage(service: service)));
    await tester.pumpAndSettle();
    final markers = tester
        .widget<MarkerLayer>(find.byType(MarkerLayer))
        .markers;
    expect(markers.length, 1);
    expect(markers.single.point.latitude, 14.6);
    expect(markers.single.key, const ValueKey('aggregate-NCR'));
    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();
    expect(find.byType(SurveillancePinDetails), findsOneWidget);
    expect(find.text('3 processed entries'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
  for (final suffix in ['', '/', '/api', '/api/']) {
    test(
      'public request normalizes base $suffix and preserves aggregation',
      () async {
        final service = HealthPhApiService(
          baseUrl: 'http://example.test$suffix',
          client: MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/api/mobile/surveillance/map-pins');
            expect(request.url.queryParameters, {
              'days': '30',
              'region': 'IVA',
              'disease': 'TB',
            });
            expect(request.headers.containsKey('authorization'), isFalse);
            return http.Response(
              jsonEncode({
                'items': [fixture()],
              }),
              200,
            );
          }),
        );
        final pins = await service.fetchSurveillanceMapPins(
          days: 30,
          region: 'IVA',
          disease: 'TB',
        );
        expect(pins.single.processedEntryCount, 3);
        expect(pins.single.diseaseCounts.values.reduce((a, b) => a + b), 4);
        expect(pins.single.latitude, 14.6);
      },
    );
  }
  test(
    'empty response succeeds; failures and malformed results never fall back',
    () async {
      var calls = 0;
      var body = '{"items":[]}';
      var status = 200;
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient((request) async {
          calls++;
          expect(request.url.path, '/api/mobile/surveillance/map-pins');
          return http.Response(body, status);
        }),
      );
      expect(await service.fetchSurveillanceMapPins(), isEmpty);
      status = 503;
      await expectLater(service.fetchSurveillanceMapPins(), throwsException);
      status = 200;
      body = '[]';
      await expectLater(
        service.fetchSurveillanceMapPins(),
        throwsFormatException,
      );
      body = jsonEncode({
        'items': [
          {...fixture(), 'latitude': 999},
        ],
      });
      await expectLater(
        service.fetchSurveillanceMapPins(),
        throwsFormatException,
      );
      expect(calls, 4);
      await expectLater(
        service.fetchSurveillanceMapPins(days: 0),
        throwsArgumentError,
      );
      await expectLater(
        service.fetchSurveillanceMapPins(days: 366),
        throwsArgumentError,
      );
      await expectLater(
        service.fetchSurveillanceMapPins(disease: 'Cough'),
        throwsArgumentError,
      );
      expect(calls, 4);
    },
  );

  testWidgets('map shows empty/error distinctly and retries without raw pins', (
    tester,
  ) async {
    var failed = false;
    final service = HealthPhApiService(
      baseUrl: 'http://example.test',
      client: MockClient((request) async {
        return http.Response('{"items":[]}', failed ? 503 : 200);
      }),
    );
    await tester.pumpWidget(MaterialApp(home: MapPage(service: service)));
    await tester.pumpAndSettle();
    expect(
      find.text('No processed disease signals for these filters.'),
      findsOneWidget,
    );
    expect(
      tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers,
      isEmpty,
    );
    failed = true;
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(find.text('Unable to load disease signals.'), findsOneWidget);
    expect(
      find.text('No processed disease signals for these filters.'),
      findsNothing,
    );
    expect(
      tester.widget<MarkerLayer>(find.byType(MarkerLayer)).markers,
      isEmpty,
    );
    failed = false;
    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();
    expect(
      find.text('No processed disease signals for these filters.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail shows processed total separately from disease counts', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SurveillancePinDetails(
            pin: SurveillancePin.fromJson(fixture()),
          ),
        ),
      ),
    );
    expect(find.text('3 processed entries'), findsOneWidget);
    expect(find.text('TB'), findsOneWidget);
    expect(find.text('PN'), findsOneWidget);
    expect(find.text('2'), findsNWidgets(2));
  });
}
