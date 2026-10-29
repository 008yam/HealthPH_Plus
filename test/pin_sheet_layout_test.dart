import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/models/surveillance_pin.dart';
import 'package:healthphplus/widgets/surveillance_pin_details.dart';
import 'package:healthphplus/widgets/weather_widget.dart';
import 'map_environmental_test.dart' show FakeWeatherService;

void main() {
  for (final size in [const Size(390, 844), const Size(844, 390)]) {
    testWidgets('combined pin content scrolls without gaps at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final pin = SurveillancePin.fromJson({
        'id': 'signal-test',
        'latitude': 14.6,
        'longitude': 121.0,
        'region': 'NCR',
        'diseaseCodes': ['TB'],
        'diseaseCounts': {'TB': 1},
        'processedEntryCount': 1,
      });
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                SurveillancePinDetails(
                  pin: pin,
                  embedded: true,
                  onClose: () => closed = true,
                ),
                WeatherWidget(
                  embedded: true,
                  lockRegion: true,
                  service: FakeWeatherService(),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(DropdownButton<String>), findsNothing);
      final details = tester.getRect(find.byType(SurveillancePinDetails));
      final weather = tester.getRect(find.byType(WeatherWidget));
      expect(weather.top, closeTo(details.bottom, 1));
      await tester.tap(find.byTooltip('Close'));
      expect(closed, isTrue);
      await tester.drag(find.byType(ListView), const Offset(0, -900));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
