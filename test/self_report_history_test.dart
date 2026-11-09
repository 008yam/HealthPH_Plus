import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthphplus/services/healthph_api_services.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:healthphplus/pages/self_report_history_page.dart';

const profile = UserProfile(
  id: 'MUSER-test',
  fullName: 'Test',
  email: 'test@example.test',
  accessToken: 'test-mobile-token',
  roleId: 'user',
  role: 'User',
  language: 'English',
  regionCode: 'NCR',
  regionLabel: 'NCR',
  province: 'Metro Manila',
  city: 'Manila',
  barangay: 'Test',
);

void main() {
  setUp(() => ProfileStore.instance.saveProfile(profile));
  tearDown(() => ProfileStore.instance.clearProfile());

  for (final suffix in ['', '/api/']) {
    for (final envelope in [true, false]) {
      test(
        'history authenticates owner; base=$suffix envelope=$envelope',
        () async {
          final rows = [
            {'id': 'SEL-test', 'notes': 'Fixture'},
          ];
          final service = HealthPhApiService(
            baseUrl: 'http://example.test$suffix',
            client: MockClient((request) async {
              expect(request.url.path, '/api/mobile/self-reports/mine');
              expect(request.url.queryParameters, isEmpty);
              expect(
                request.headers['Authorization'],
                'Bearer test-mobile-token',
              );
              return http.Response(
                jsonEncode(envelope ? {'items': rows} : rows),
                200,
              );
            }),
          );
          expect(
            await service.fetchMySelfReports(
              accessToken: ' test-mobile-token ',
            ),
            rows,
          );
        },
      );
    }
  }

  test(
    'missing token does not request history; 401 is not empty history',
    () async {
      var calls = 0;
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient((_) async {
          calls++;
          return http.Response('{}', 401);
        }),
      );
      await expectLater(
        service.fetchMySelfReports(accessToken: null),
        throwsA(isA<SelfReportAuthenticationException>()),
      );
      expect(calls, 0);
      await expectLater(
        service.fetchMySelfReports(accessToken: 'expired'),
        throwsA(isA<SelfReportAuthenticationException>()),
      );
      expect(calls, 1);
    },
  );

  test('malformed success does not become empty history', () async {
    final service = HealthPhApiService(
      baseUrl: 'http://example.test',
      client: MockClient((_) async => http.Response('{"unexpected":[]}', 200)),
    );
    await expectLater(
      service.fetchMySelfReports(accessToken: 'token'),
      throwsFormatException,
    );
  });

  testWidgets(
    '401 shows sign-in, not empty reports or an unhandled exception',
    (tester) async {
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient((_) async => http.Response('{}', 401)),
      );
      await tester.pumpWidget(
        MaterialApp(home: SelfReportHistoryPage(service: service)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Your session has expired or is invalid. Please sign in again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('No self-reports yet'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed refresh stays handled, then successful retry shows empty history',
    (tester) async {
      var status = 503;
      final service = HealthPhApiService(
        baseUrl: 'http://example.test',
        client: MockClient((_) async => http.Response('{"items":[]}', status)),
      );
      await tester.pumpWidget(
        MaterialApp(home: SelfReportHistoryPage(service: service)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('No self-reports yet'), findsNothing);
      status = 200;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('No self-reports yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
