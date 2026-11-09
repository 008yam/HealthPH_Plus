import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthphplus/models/sentiment_pulse_report.dart';
import 'package:healthphplus/models/sentiment_report_filters.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:healthphplus/services/sentiment_reporting_service.dart';
import 'package:healthphplus/services/sentiment_reporting_controller.dart';
import 'package:healthphplus/pages/sentiment_pulse_page.dart';
import 'package:healthphplus/widgets/sentiment_report_sections.dart';
import 'sentiment_reporting_test.dart' show fixture, legacyFixture;

UserProfile account({
  String id = 'test-user',
  String token = 'synthetic-token',
  String region = 'NCR',
}) => UserProfile(
  id: id,
  accessToken: token,
  fullName: 'Test',
  email: 'test@example.invalid',
  roleId: 'user',
  role: 'User',
  language: 'English',
  regionCode: region,
  regionLabel: region,
  province: '',
  city: '',
  barangay: '',
);

Map<String, dynamic> responseFor(Uri uri) {
  final json = fixture();
  json['filters']['timeRange'] = uri.queryParameters['timeRange'];
  json['filters']['regions'] = uri.queryParameters.containsKey('regions')
      ? [uri.queryParameters['regions']]
      : [];
  json['filters']['surveyId'] = uri.queryParameters['surveyId'];
  if (uri.queryParameters['regionalRegion'] case final String region) {
    json['regional']['regionCode'] = region;
    json['regional']['regionLabel'] = region;
    json['regional']['regionSource'] = 'selection';
    json['regional']['filters']['regions'] = [region];
  }
  return json;
}

void main() {
  tearDown(() => ProfileStore.instance.clearProfile());
  test('missing baseline and incomplete Regional counts remain null', () {
    final json = fixture();
    json['sentimentTrends']['overviewChange'] = {'calm': null, 'worried': null};
    json['sentimentTrends']['surveys'][0]['changeFromOverviewBaseline'] = {
      'calm': null,
      'worried': null,
    };
    final report = SentimentPulseReport.fromJson(json);
    expect(report.sentimentTrends.overviewChange.calm, isNull);
    expect(
      report.sentimentTrends.surveys.single.changeFromOverviewBaseline.calm,
      isNull,
    );
    expect(report.regional.analyzedSubmissions, isNull);
    expect(report.regional.linkedAnalyzedSubmissions, 2);
    expect(report.regional.submissionCountStatus, 'incomplete');
  });
  test(
    'one-day and future-end windows preserve Philippine dates and cutoff',
    () {
      for (final end in ['2026-10-28', '2026-11-04']) {
        final json = fixture();
        final start = DateTime.utc(2026, 10, 28);
        final last = reportDate(end);
        final previousEnd = start.subtract(const Duration(days: 1));
        final previousStart = previousEnd.subtract(
          Duration(days: last.difference(start).inDays),
        );
        json['filters']['timeRange'] = 'custom';
        json['filters']['startDate'] = '2026-10-28';
        json['filters']['endDate'] = end;
        json['sentimentTrends']['baseline']['startDate'] = previousStart
            .toIso8601String()
            .substring(0, 10);
        json['sentimentTrends']['baseline']['endDate'] = '2026-10-27';
        final report = SentimentPulseReport.fromJson(json);
        expect(report.filters['endDate'], end);
        expect(report.asOf, '2026-10-29T12:00:00+08:00');
      }
    },
  );
  test('custom query keeps Overview and Regional scopes separate', () async {
    final client = MockClient((request) async {
      expect(request.url.queryParameters, {
        'timeRange': 'custom',
        'startDate': '2026-10-28',
        'endDate': '2026-11-04',
        'regions': 'NCR',
        'regionalRegion': 'III',
        'surveyId': 'SUR00012',
      });
      return http.Response(jsonEncode(fixture()), 200);
    });
    await SentimentReportingService(
      baseUrl: 'http://example.test/api',
      client: client,
    ).fetch(
      accessToken: 'test-token',
      filters: const SentimentReportFilters(
        timeRange: 'custom',
        startDate: '2026-10-28',
        endDate: '2026-11-04',
        region: 'NCR',
        regionalRegion: 'III',
        surveyId: 'SUR00012',
      ),
    );
    client.close();
  });
  test(
    'network failure and malformed JSON become errors without cached totals',
    () async {
      ProfileStore.instance.saveProfile(account());
      var malformed = false;
      final client = MockClient((_) async {
        if (malformed) return http.Response('<html>sign in</html>', 200);
        throw http.ClientException('Offline');
      });
      final controller = SentimentReportingController(
        SentimentReportingService(
          baseUrl: 'http://example.test',
          client: client,
        ),
      );
      await controller.refresh();
      expect(controller.report, isNull);
      expect(controller.error, isNotNull);
      malformed = true;
      await controller.refresh();
      expect(controller.report, isNull);
      expect(controller.error, contains('Incompatible'));
      controller.dispose();
      client.close();
    },
  );
  test('switching accounts discards the old account response', () async {
    ProfileStore.instance.saveProfile(account());
    final old = Completer<http.Response>();
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      if (calls == 1) return old.future;
      expect(request.headers['Authorization'], 'Bearer second-token');
      final json = responseFor(request.url);
      json['regional']['regionLabel'] = 'Second account region';
      return http.Response(jsonEncode(json), 200);
    });
    final controller = SentimentReportingController(
      SentimentReportingService(baseUrl: 'http://example.test', client: client),
    );
    final first = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    ProfileStore.instance.saveProfile(
      account(id: 'second', token: 'second-token'),
    );
    await Future<void>.delayed(Duration.zero);
    old.complete(http.Response(jsonEncode(fixture()), 200));
    await first;
    expect(controller.report!.regional.regionLabel, 'Second account region');
    controller.dispose();
    client.close();
  });
  testWidgets('Overview uses server weighted shares, not mean survey shares', (
    tester,
  ) async {
    final json = fixture();
    json['sentimentDistribution'] = [
      {'category': 'calm', 'answers': 4, 'share': 400 / 7},
      {'category': 'worried', 'answers': 3, 'share': 300 / 7},
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OverviewTab(report: SentimentPulseReport.fromJson(json)),
        ),
      ),
    );
    expect(find.text('57.1%'), findsOneWidget);
    expect(find.text('62.5%'), findsNothing);
  });
  testWidgets(
    'Trends labels both comparisons and never substitutes satisfaction',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrendsTab(report: SentimentPulseReport.fromJson(fixture())),
          ),
        ),
      );
      expect(find.text('vs previous Overview'), findsOneWidget);
      expect(find.text("vs this survey's previous period"), findsOneWidget);
      expect(find.text('Calm: -25.0 pp'), findsOneWidget);
      expect(find.text('Calm: -50.0 pp'), findsOneWidget);
      expect(find.text('Daily satisfied share'), findsNothing);
    },
  );
  testWidgets('recognized empty region is not a missing region', (
    tester,
  ) async {
    final json = fixture();
    json['regional']['sentiment'] = {
      'status': 'configured',
      'dominantCategory': null,
      'dominantShare': null,
      'eligibleAnswers': 0,
      'predictedAnswers': 0,
      'answersWithoutResults': 0,
      'analysisCoverage': null,
    };
    json['regional']['sentimentDistribution'] = [
      {'category': 'calm', 'answers': 0, 'share': null},
      {'category': 'worried', 'answers': 0, 'share': null},
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RegionalTab(report: SentimentPulseReport.fromJson(json)),
        ),
      ),
    );
    expect(find.text('No eligible answers'), findsOneWidget);
    expect(find.text('Choose region'), findsNothing);
    expect(find.text('National Capital Region'), findsOneWidget);
  });
  for (final suffix in ['', '/', '/api', '/api/']) {
    test('authenticated single mobile request normalizes $suffix', () async {
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        expect(request.method, 'GET');
        expect(request.url.path, '/api/mobile/sentiment-pulse/trends');
        expect(request.url.hasFragment, false);
        expect(request.headers['Authorization'], 'Bearer synthetic-token');
        expect(request.headers['Accept'], 'application/json');
        expect(request.url.queryParameters, {
          'timeRange': 'last-30-days',
          'regionalRegion': 'III',
        });
        return http.Response(jsonEncode(responseFor(request.url)), 200);
      });
      final service = SentimentReportingService(
        baseUrl: 'https://example.test$suffix',
        client: client,
      );
      final report = await service.fetch(
        accessToken: 'synthetic-token',
        filters: const SentimentReportFilters(regionalRegion: 'III'),
      );
      expect(calls, 1);
      expect(report.regional.regionCode, 'III');
      expect(report.filters['regions'], isEmpty);
      client.close();
    });
  }
  test('old deployment missing new blocks is rejected', () {
    expect(
      () => SentimentPulseReport.fromJson(legacyFixture()),
      throwsFormatException,
    );
    for (final key in ['regional', 'sentimentTrends', 'asOf']) {
      expect(
        () => SentimentPulseReport.fromJson(fixture()..remove(key)),
        throwsFormatException,
      );
    }
    final json = fixture();
    json['sentimentTrends'].remove('baseline');
    expect(() => SentimentPulseReport.fromJson(json), throwsFormatException);
  });
  test('survey comparisons retain both distinct signed deltas', () {
    final report = SentimentPulseReport.fromJson(fixture());
    final survey = report.sentimentTrends.surveys.single;
    expect(survey.changeFromOverviewBaseline.calm, -25);
    expect(survey.changeFromPreviousPeriod.calm, -50);
    expect(survey.changeFromOverviewBaseline.worried, 25);
    expect(survey.changeFromPreviousPeriod.worried, 50);
    expect(survey.title, 'Ended survey A');
    expect(reportingChange(-0.001), '0.0 pp');
    expect(reportingChange(25), '+25.0 pp');
    expect(reportingChange(null), '');
  });
  test('empty regional variant does not fabricate metrics', () {
    final json = fixture();
    final filters = json['regional']['filters'] as Map<String, dynamic>;
    json['regional'] = {
      'status': 'region_required',
      'regionCode': null,
      'regionLabel': null,
      'regionSource': 'profile',
      'filters': {...filters, 'regions': []},
    };
    final report = SentimentPulseReport.fromJson(json);
    expect(report.regional.sentiment, isNull);
    expect(report.regional.analyzedSubmissions, isNull);
    expect(report.sentiment.predictedAnswers, 130);
  });
  for (final status in [400, 401, 403, 404, 422, 500, 503]) {
    test(
      'HTTP $status with structured detail never becomes an empty report',
      () async {
        final client = MockClient(
          (_) async => http.Response('{"detail":[{"msg":"private"}]}', status),
        );
        final service = SentimentReportingService(
          baseUrl: 'http://example.test',
          client: client,
        );
        await expectLater(
          service.fetch(
            accessToken: 'synthetic-token',
            filters: const SentimentReportFilters(),
          ),
          throwsA(
            isA<SentimentReportingException>().having(
              (e) => e.status,
              'status',
              status,
            ),
          ),
        );
        client.close();
      },
    );
  }
  test('newer filters win and logout invalidates in-flight response', () async {
    ProfileStore.instance.saveProfile(account());
    final requests = <Uri>[];
    final pending = <Completer<http.Response>>[];
    final client = MockClient((request) {
      requests.add(request.url);
      final c = Completer<http.Response>();
      pending.add(c);
      return c.future;
    });
    final controller = SentimentReportingController(
      SentimentReportingService(baseUrl: 'http://example.test', client: client),
    );
    final first = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    controller.select(const SentimentReportFilters(regionalRegion: 'III'));
    await Future<void>.delayed(Duration.zero);
    pending[1].complete(
      http.Response(jsonEncode(responseFor(requests[1])), 200),
    );
    await Future<void>.delayed(Duration.zero);
    expect(controller.report!.regional.regionCode, 'III');
    pending[0].complete(
      http.Response(jsonEncode(responseFor(requests[0])), 200),
    );
    await first;
    expect(controller.report!.regional.regionCode, 'III');
    final third = controller.refresh();
    await Future<void>.delayed(Duration.zero);
    ProfileStore.instance.clearProfile();
    pending[2].complete(
      http.Response(jsonEncode(responseFor(requests[2])), 200),
    );
    await third;
    expect(controller.report, isNull);
    expect(controller.authenticationRequired, isTrue);
    expect(controller.filters.regionalRegion, isNull);
    controller.dispose();
    client.close();
  });
  test(
    'profile region change refreshes without restricting national Overview',
    () async {
      ProfileStore.instance.saveProfile(account());
      var calls = 0;
      final client = MockClient((request) async {
        calls++;
        expect(request.url.queryParameters.containsKey('regions'), false);
        expect(
          request.url.queryParameters.containsKey('regionalRegion'),
          false,
        );
        return http.Response(jsonEncode(responseFor(request.url)), 200);
      });
      final controller = SentimentReportingController(
        SentimentReportingService(
          baseUrl: 'http://example.test',
          client: client,
        ),
      );
      await controller.refresh();
      ProfileStore.instance.saveProfile(account(region: 'III'));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 2);
      controller.dispose();
      client.close();
    },
  );
  test('401 clears expired session and does not loop', () async {
    ProfileStore.instance.saveProfile(account());
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return http.Response('{}', 401);
    });
    final controller = SentimentReportingController(
      SentimentReportingService(baseUrl: 'http://example.test', client: client),
    );
    await controller.refresh();
    expect(ProfileStore.instance.profile, isNull);
    expect(controller.authenticationRequired, true);
    expect(controller.loading, false);
    expect(calls, 1);
    controller.dispose();
    client.close();
  });
  testWidgets('all three tabs share a single request and regional values', (
    tester,
  ) async {
    ProfileStore.instance.saveProfile(account());
    var calls = 0;
    final client = MockClient((request) async {
      calls++;
      return http.Response(jsonEncode(responseFor(request.url)), 200);
    });
    await tester.pumpWidget(
      MaterialApp(
        home: SentimentPulsePage(
          reportingService: SentimentReportingService(
            baseUrl: 'http://example.test',
            client: client,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.tap(find.text('Trends'));
    await tester.pumpAndSettle();
    expect(find.text('Ended survey A'), findsOneWidget);
    await tester.tap(find.text('Regional'));
    await tester.pumpAndSettle();
    expect(find.text('National Capital Region'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
    expect(find.text('65.4%'), findsNothing);
    expect(calls, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    client.close();
  });
  testWidgets(
    'regional required has actionable selection, not national counts',
    (tester) async {
      final json = fixture();
      final filters = json['regional']['filters'];
      json['regional'] = {
        'status': 'region_required',
        'regionCode': null,
        'regionLabel': null,
        'regionSource': 'profile',
        'filters': {...filters as Map<String, dynamic>, 'regions': []},
      };
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegionalTab(
              report: SentimentPulseReport.fromJson(json),
              onChooseRegion: () => taps++,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Choose region'));
      expect(taps, 1);
      expect(find.text('65.4%'), findsNothing);
    },
  );
}
