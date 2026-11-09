import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthphplus/pages/map_page.dart';
import 'package:healthphplus/services/app_settings_store.dart';
import 'package:healthphplus/services/healthph_api_services.dart';
import 'package:healthphplus/theme/app_theme.dart';
import 'package:healthphplus/widgets/floating_navbar.dart';

void main() {
  test('dark changes the background but shares default control colors', () {
    final normal = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;
    expect(dark.colorScheme, normal.colorScheme);
    expect(dark.elevatedButtonTheme, normal.elevatedButtonTheme);
    expect(dark.inputDecorationTheme, normal.inputDecorationTheme);
    expect(
      HealthPhVisualMode.dark.accentColor,
      HealthPhVisualMode.appDefault.accentColor,
    );
    expect(
      HealthPhVisualMode.dark.backgroundAsset,
      isNot(HealthPhVisualMode.appDefault.backgroundAsset),
    );
    expect(HealthPhVisualMode.dark.onBackground, Colors.white);
  });

  for (final size in [const Size(420, 900), const Size(850, 390)]) {
    testWidgets(
      'map fills behind light navbar at $size; weather stays above it',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final settings = AppSettingsStore.instance;
        final previous = settings.visualMode;
        settings.visualMode = HealthPhVisualMode.dark;
        addTearDown(() => settings.visualMode = previous);
        final service = HealthPhApiService(
          baseUrl: 'http://example.test',
          client: MockClient((_) async => http.Response('{"items":[]}', 200)),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(bottom: 24)),
              child: child!,
            ),
            home: MapPage(service: service),
          ),
        );
        await tester.pumpAndSettle();
        final map = tester.getRect(find.byType(FlutterMap));
        final scaffold = tester.getRect(find.byType(Scaffold).first);
        final nav = tester.getRect(find.byType(FloatingNavBar));
        final menu = tester.getRect(
          find.byKey(const ValueKey('weather-menu-toggle')),
        );
        expect(map.bottom, closeTo(scaffold.bottom, 0.01));
        expect(map.bottom, greaterThan(nav.top));
        expect(menu.bottom, lessThan(nav.top));
        final navContainers = tester.widgetList<Container>(
          find.descendant(
            of: find.byType(FloatingNavBar),
            matching: find.byType(Container),
          ),
        );
        expect(
          navContainers.any(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration as BoxDecoration).color == Colors.white,
          ),
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}
