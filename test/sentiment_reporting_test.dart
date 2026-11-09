import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/localization/app_translations.dart';
import 'package:healthphplus/localization/sentiment_reporting_translations.dart';
import 'package:healthphplus/models/sentiment_pulse_report.dart';
import 'package:healthphplus/models/sentiment_report_filters.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/widgets/satisfaction_trend_chart.dart';
import 'package:healthphplus/widgets/sentiment_report_filter_sheet.dart';

// Synthetic handoff data only. Never imported by application code.
Map<String, dynamic> legacyFixture() =>
    jsonDecode('''{
  "sources": ["mobile"],
  "filters": {"timeRange":"last-30-days", "startDate":"2026-09-30",
    "endDate":"2026-10-29", "regions":[], "surveyId":null,
    "unknownRegionIncluded":true, "timezone":"Asia/Manila",
    "surveyVisibility":"published-to-mobile", "participants":"all"},
  "sentiment":{"status":"configured","dominantCategory":"calm",
    "dominantShare":65.38461538461539,"eligibleAnswers":160,
    "predictedAnswers":130,"answersWithoutResults":30,"analysisCoverage":81.25},
  "satisfaction":{"status":"configured","satisfactionAnswers":10,
    "satisfiedAnswers":6,"satisfactionShare":60.0},
  "sentimentDistribution":[{"category":"calm","answers":85,"share":65.38461538461539},
    {"category":"worried","answers":45,"share":34.61538461538461}],
  "satisfactionDistribution":[{"category":"satisfied","answers":6,"share":60},
    {"category":"neutral","answers":1,"share":10},
    {"category":"dissatisfied","answers":3,"share":30}],
  "satisfactionTrend":[{"date":"2026-10-27","satisfactionAnswers":4,
    "satisfiedAnswers":1,"satisfactionShare":25},
    {"date":"2026-10-29","satisfactionAnswers":6,
    "satisfiedAnswers":5,"satisfactionShare":83.33333333333334}]
}''')
        as Map<String, dynamic>;

Map<String, dynamic> fixture() {
  final json = legacyFixture();
  Map<String, dynamic> summary(int calm, int worried) => {
    'status': 'configured',
    'dominantCategory': calm == worried
        ? 'tie'
        : calm > worried
        ? 'calm'
        : 'worried',
    'dominantShare': 100 * (calm > worried ? calm : worried) / (calm + worried),
    'eligibleAnswers': calm + worried,
    'predictedAnswers': calm + worried,
    'answersWithoutResults': 0,
    'analysisCoverage': 100,
  };
  List<Map<String, dynamic>> distribution(int calm, int worried) => [
    {
      'category': 'calm',
      'answers': calm,
      'share': 100 * calm / (calm + worried),
    },
    {
      'category': 'worried',
      'answers': worried,
      'share': 100 * worried / (calm + worried),
    },
  ];
  json['asOf'] = '2026-10-29T12:00:00+08:00';
  json['sentimentTrends'] = {
    'comparison': 'previous-equal-calendar-period',
    'changeUnit': 'percentage-points',
    'baseline': {
      'startDate': '2026-08-31',
      'endDate': '2026-09-29',
      'sentiment': summary(1, 1),
      'sentimentDistribution': distribution(1, 1),
    },
    'overviewChange': {
      'calm': 15.38461538461539,
      'worried': -15.38461538461539,
    },
    'surveys': [
      {
        'surveyId': 'SUR00012',
        'title': 'Ended survey A',
        'sentiment': summary(1, 3),
        'sentimentDistribution': distribution(1, 3),
        'previousSentiment': summary(3, 1),
        'previousSentimentDistribution': distribution(3, 1),
        'changeFromOverviewBaseline': {'calm': -25, 'worried': 25},
        'changeFromPreviousPeriod': {'calm': -50, 'worried': 50},
      },
    ],
  };
  json['regional'] = {
    'status': 'available',
    'regionCode': 'NCR',
    'regionLabel': 'National Capital Region',
    'regionSource': 'profile',
    'filters': {
      ...json['filters'] as Map<String, dynamic>,
      'regions': ['NCR'],
      'unknownRegionIncluded': false,
      'surveyVisibility': 'all-existing-surveys',
    },
    'sentiment': summary(1, 3),
    'sentimentDistribution': distribution(1, 3),
    'satisfaction': json['satisfaction'],
    'satisfactionDistribution': json['satisfactionDistribution'],
    'analyzedSubmissions': null,
    'linkedAnalyzedSubmissions': 2,
    'submissionCountStatus': 'incomplete',
    'satisfactionScope': 'linked_analyzed_submissions',
  };
  return json;
}

void main() {
  test('parses integer percentages, null categories, and measured zeros', () {
    final json = fixture();
    json['satisfactionDistribution'][1]['answers'] = null;
    json['satisfactionDistribution'][1]['share'] = null;
    json['sentimentDistribution'][1]['share'] = 0;
    final report = SentimentPulseReport.fromJson(json);
    expect(report.satisfaction.satisfactionShare, 60.0);
    expect(report.satisfactionDistribution[1].answers, isNull);
    expect(report.satisfactionDistribution[1].share, isNull);
    expect(report.sentimentDistribution[1].share, 0.0);
  });
  test('invalid mandatory fields and dates produce controlled errors', () {
    for (final key in [
      'sentiment',
      'satisfaction',
      'filters',
      'satisfactionTrend',
    ]) {
      final json = fixture()..remove(key);
      expect(() => SentimentPulseReport.fromJson(json), throwsFormatException);
    }
    final json = fixture();
    json['satisfactionTrend'][0]['date'] = '2026-02-30';
    expect(() => SentimentPulseReport.fromJson(json), throwsFormatException);
    json['satisfactionTrend'][0]['date'] = '2026-10-27';
    json['sentiment']['dominantShare'] = 101;
    expect(() => SentimentPulseReport.fromJson(json), throwsFormatException);
  });
  test(
    'calendar dates do not shift and chart does not bridge missing days',
    () {
      final points = SentimentPulseReport.fromJson(fixture()).satisfactionTrend;
      expect(reportDate('2026-10-28'), DateTime.utc(2026, 10, 28));
      expect(satisfactionSegments(points).map((s) => s.length), [1, 1]);
      const missing = SatisfactionTrendPoint(
        date: '2026-10-28',
        satisfactionAnswers: 0,
        satisfiedAnswers: 0,
        satisfactionShare: null,
      );
      expect(
        satisfactionSegments([points.first, missing, points.last]).length,
        2,
      );
      const zero = SatisfactionTrendPoint(
        date: '2026-10-28',
        satisfactionAnswers: 1,
        satisfiedAnswers: 0,
        satisfactionShare: 0,
      );
      expect(
        satisfactionSegments([points.first, zero, points.last]).single.length,
        3,
      );
    },
  );
  test('filters omit unused dates and region, and validate custom dates', () {
    expect(const SentimentReportFilters().toQuery(), {
      'timeRange': 'last-30-days',
    });
    for (final range in ['last-7-days', 'last-30-days', 'last-90-days']) {
      expect(
        SentimentReportFilters(timeRange: range, region: 'NCR').toQuery(),
        {'timeRange': range, 'regions': 'NCR'},
      );
    }
    expect(
      const SentimentReportFilters(
        timeRange: 'custom',
        region: 'III',
        startDate: '2026-10-27',
        endDate: '2026-10-29',
      ).toQuery(),
      {
        'timeRange': 'custom',
        'regions': 'III',
        'startDate': '2026-10-27',
        'endDate': '2026-10-29',
      },
    );
    expect(
      () => const SentimentReportFilters(timeRange: 'custom').toQuery(),
      throwsFormatException,
    );
    expect(
      () => const SentimentReportFilters(
        timeRange: 'custom',
        startDate: '2026-10-29',
        endDate: '2026-10-27',
      ).toQuery(),
      throwsFormatException,
    );
  });
  test(
    'translations preserve every placeholder in every supported language',
    () {
      final parameter = RegExp(r'\{[^}]+\}');
      for (final language in sentimentReportingTranslations.entries) {
        for (final item in language.value.entries) {
          expect(item.value.trim(), isNotEmpty);
          expect(
            parameter.allMatches(item.value).map((m) => m.group(0)).toSet(),
            parameter.allMatches(item.key).map((m) => m.group(0)).toSet(),
          );
          expect(translateText(item.key, language.key), isNot(item.key));
        }
      }
    },
  );

  Future<void> render(
    WidgetTester tester,
    Widget child, {
    Size size = const Size(390, 844),
    double scale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('overview uses supplied totals, not fabricated percentages', (
    tester,
  ) async {
    await render(
      tester,
      OverviewTab(report: SentimentPulseReport.fromJson(fixture())),
    );
    expect(find.text('65.4%'), findsOneWidget);
    expect(find.text('130/160 analyzed; 30 without results'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.text('60.0%'), findsWidgets);
    expect(find.text('6/10 answers satisfied'), findsOneWidget);
  });
  testWidgets('tie, no results, and not-configured have distinct labels', (
    tester,
  ) async {
    final json = fixture();
    json['sentiment']['dominantCategory'] = 'tie';
    json['sentiment']['dominantShare'] = 50;
    await render(
      tester,
      OverviewTab(report: SentimentPulseReport.fromJson(json)),
    );
    expect(find.text('Calm / Worried: 50% each'), findsOneWidget);
    json['sentiment']['dominantCategory'] = null;
    json['sentiment']['dominantShare'] = null;
    json['sentiment']['predictedAnswers'] = 0;
    await render(
      tester,
      OverviewTab(report: SentimentPulseReport.fromJson(json)),
    );
    expect(find.text('No results yet'), findsOneWidget);
    json['sentiment']['status'] = 'not_configured';
    await render(
      tester,
      OverviewTab(report: SentimentPulseReport.fromJson(json)),
    );
    expect(find.text('Not configured'), findsOneWidget);
  });
  for (final size in [const Size(320, 568), const Size(844, 390)]) {
    testWidgets('report page fits $size with enlarged text', (tester) async {
      await render(
        tester,
        SentimentPulsePage(report: SentimentPulseReport.fromJson(fixture())),
        size: size,
        scale: 1.6,
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Trends'));
      await tester.tap(find.text('Trends'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TrendsTab), findsOneWidget);
      await tester.drag(find.byType(ListView).last, const Offset(0, -1600));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Regional'));
      await tester.tap(find.text('Regional'));
      await tester.pumpAndSettle();
      expect(find.byType(RegionalTab), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'filter change hides stale report and remains shared across tabs',
    (tester) async {
      SentimentReportFilters? selection;
      await render(
        tester,
        SentimentPulsePage(
          report: SentimentPulseReport.fromJson(fixture()),
          onReportFiltersChanged: (value) => selection = value,
        ),
      );
      await tester.tap(find.byTooltip('Reporting filters').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Last 7 days').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(selection!.toQuery(), {'timeRange': 'last-7-days'});
      expect(find.text('Calm · 65.4%'), findsNothing);
      expect(
        find.text('Selected filters have not been loaded yet.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Trends'));
      await tester.pumpAndSettle();
      expect(find.text('Last 7 days · All regions'), findsOneWidget);
    },
  );
  testWidgets('unconnected and error states never show zero reports', (
    tester,
  ) async {
    await render(tester, const SentimentPulsePage());
    expect(find.text('Sign in to view reporting data.'), findsOneWidget);
    var retries = 0;
    await render(
      tester,
      SentimentPulsePage(
        reportError: 'Unavailable',
        onRetryReport: () => retries++,
      ),
    );
    await tester.tap(find.text('Retry'));
    expect(retries, 1);
    expect(find.text('0.0%'), findsNothing);
  });
  testWidgets('custom dates cannot apply until a range is chosen', (
    tester,
  ) async {
    await render(
      tester,
      const SentimentReportFilterSheet(
        initial: SentimentReportFilters(timeRange: 'custom'),
      ),
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });
  testWidgets('trend renders daily counts and a nonblank gap-aware chart', (
    tester,
  ) async {
    await render(
      tester,
      OverviewTab(report: SentimentPulseReport.fromJson(fixture())),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily satisfied share'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.textContaining('2026-10-27: 25.0%'), findsOneWidget);
    expect(find.textContaining('2026-10-29: 83.3%'), findsOneWidget);
    expect(find.textContaining('5/6 answers satisfied'), findsOneWidget);
    final painter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((widget) => widget.painter)
        .whereType<SatisfactionTrendPainter>()
        .single;
    expect(painter.segments.length, 2);
    expect(tester.takeException(), isNull);
  });
  testWidgets('loading hides prior totals without showing an empty report', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SentimentPulsePage(
          report: SentimentPulseReport.fromJson(fixture()),
          reportLoading: true,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Calm · 65.4%'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
