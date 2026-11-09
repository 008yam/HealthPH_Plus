import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/localization/app_translations.dart';
import 'package:healthphplus/models/mobile_alert.dart';
import 'package:healthphplus/models/sentiment_pulse_report.dart';
import 'package:healthphplus/pages/disease_watch_page.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/services/mobile_alert_service.dart';
import 'package:healthphplus/widgets/sentiment_visuals.dart';
import 'sentiment_reporting_test.dart' show fixture;

class DesignAlerts extends MobileAlertService {
  DesignAlerts() : super(baseUrl: 'http://unused');
  @override
  Future<MobileAlertsPage> fetchAlerts({
    int limit = 20,
    String? cursor,
    String? accessToken,
  }) async => MobileAlertsPage(
    items: [
      MobileAlert.fromJson({
        'id': 'new',
        'title': 'Respiratory disease signals',
        'regionName': 'National Capital Region',
        'message':
            'A regional health alert is available. Review the latest guidance and updates.',
        'reportCount': 12,
        'publishedAt': '2026-11-06T08:00:00+08:00',
      }),
      MobileAlert.fromJson({
        'id': 'old',
        'title': 'Community health update',
        'regionName': 'CALABARZON',
        'reportCount': 8,
        'message': 'Updated community guidance for the region.',
        'readAt': '2026-11-05T08:00:00+08:00',
      }),
    ],
    nextCursor: null,
    unreadCount: 1,
  );
}

void main() {
  const capture = bool.fromEnvironment('CAPTURE_DESIGNS');
  setUpAll(() async {
    if (capture) {
      final font = FontLoader('Roboto')
        ..addFont(
          File(
            '/System/Library/Fonts/Supplemental/Arial.ttf',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
      await font.load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    }
  });
  for (final size in [
    const Size(390, 844),
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    for (final tab in [0, 1, 2, 3]) {
      testWidgets('dashboard $tab fits $size', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final key = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(size.width == 320 ? 1.8 : 1),
                ),
                child: AppLanguageScope(
                  language: size.width == 320 ? 'Filipino' : 'English',
                  child: child!,
                ),
              ),
              home: tab == 3
                  ? DiseaseWatchPage(alertService: DesignAlerts())
                  : SentimentPulsePage(
                      initialTabIndex: tab,
                      report: SentimentPulseReport.fromJson(fixture()),
                    ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (capture && size.width == 390) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              '/tmp/healthph-dashboard-$tab.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        if (tab == 0 && size.width == 390) {
          expect(find.byType(SentimentRing), findsOneWidget);
          final render = tester.renderObject<RenderBox>(
            find.byType(SentimentRing),
          );
          expect(render.size.height, greaterThan(150));
        }
        if (tab == 1) {
          expect(find.byType(SentimentComparisonColumns), findsOneWidget);
          expect(find.byType(SentimentPeriodBars), findsNothing);
        }
        if (tab == 2 && size.width == 390) {
          expect(find.byType(RegionalSentimentSplit), findsOneWidget);
        }
        final lists = find.byType(ListView);
        if (lists.evaluate().isNotEmpty) {
          await tester.drag(lists.last, const Offset(0, -900));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('read filters and search compose', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DiseaseWatchPage(alertService: DesignAlerts())),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(SegmentedButton<String>),
        matching: find.text('Read'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Respiratory disease signals'), findsNothing);
    expect(find.text('Community health update'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pumpAndSettle();
    expect(find.text('No matching alerts.'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear'));
    await tester.pumpAndSettle();
    expect(find.text('Community health update'), findsOneWidget);
    expect(find.text('Active Outbreaks'), findsNothing);
    expect(find.text('Severity'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('comparison columns preserve missing periods and exact shares', (
    tester,
  ) async {
    const current = [
      SentimentDistributionItem(category: 'calm', answers: 1, share: 33.3),
      SentimentDistributionItem(category: 'worried', answers: 2, share: 66.7),
    ];
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SentimentComparisonColumns(previous: [], current: current),
        ),
      ),
    );
    expect(find.text('Unavailable'), findsOneWidget);
    final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
    expect(tooltip.message, 'Calm: 33.3%\nWorried: 66.7%');
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing distributions do not paint zero-valued rings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SentimentRing(
                items: [
                  SentimentDistributionItem(
                    category: 'calm',
                    answers: 0,
                    share: null,
                  ),
                ],
              ),
              SatisfactionDonut(items: [], share: null),
            ],
          ),
        ),
      ),
    );
    for (final type in [SentimentRing, SatisfactionDonut]) {
      expect(
        find.descendant(
          of: find.byType(type),
          matching: find.byType(CustomPaint),
        ),
        findsNothing,
      );
    }
    expect(tester.takeException(), isNull);
  });
}
