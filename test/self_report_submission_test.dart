import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthphplus/services/healthph_api_services.dart';
import 'package:healthphplus/services/profile_store.dart';
import 'package:healthphplus/services/self_report_store.dart';

UserProfile profile({String? token, String role = 'user'}) => UserProfile(
  id: 'MUSER-test',
  fullName: 'Test User',
  email: 'test@example.com',
  accessToken: token,
  roleId: role,
  role: role,
  language: 'Cebuano',
  regionCode: 'NCR',
  regionLabel: 'NCR',
  province: 'Metro Manila',
  city: 'Manila',
  barangay: 'Test',
);

final report = SelfReport(
  region: 'NCR',
  province: 'Metro Manila',
  city: 'Manila',
  barangay: 'Test',
  symptomIds: ['cough'],
  symptoms: ['Cough'],
  possibleConditionId: 'other',
  possibleCondition: 'Other',
  notes: 'Test notes',
  createdAt: DateTime.utc(2026, 10, 13),
);

Future<SelfReportSubmissionResult> submit(
  http.Client client, [
  String base = 'http://localhost:8000',
]) => HealthPhApiService(
  baseUrl: base,
  client: client,
).submitSelfReport(report: report, regionName: 'NCR');

http.Response accepted([int status = 201]) => http.Response(
  jsonEncode({
    'message': 'Self-report submitted successfully',
    'item': {
      'id': 'SEL-test',
      'status': 'submitted',
      'analyticsEntryId': 'server-id',
    },
    'analyticsEntryId': 'server-id',
  }),
  status,
);

void main() {
  setUp(() => ProfileStore.instance.clearProfile());
  tearDown(() => ProfileStore.instance.clearProfile());

  test('registered request sends token and only self-report data', () async {
    ProfileStore.instance.saveProfile(profile(token: 'test-token'));
    var calls = 0;
    final result = await submit(
      MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'http://localhost:8000/api/mobile/self-reports',
        );
        expect(request.headers['Authorization'], 'Bearer test-token');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['reporter']['reporterType'], 'registered');
        expect(body['symptomIds'], ['cough']);
        expect(body['notes'], 'Test notes');
        expect(body['location']['cityName'], 'Manila');
        expect(body['createdAt'], '2026-10-13T00:00:00.000Z');
        void check(Object? value) {
          if (value is Map) {
            for (final key in [
              'analyticsEntryId',
              'analysis_status',
              'analysis_tasks',
              'analysis',
              'language',
            ]) {
              expect(value.containsKey(key), isFalse);
            }
            value.values.forEach(check);
          } else if (value is List) {
            value.forEach(check);
          }
        }

        check(body);
        return accepted();
      }),
    );
    expect(calls, 1);
    expect(result.id, 'SEL-test');
    expect(result.status, 'submitted');
    expect(result.analyticsEntryId, 'server-id');
  });

  for (final guest in [false, true]) {
    test(
      'guest request omits authorization, explicit profile: $guest',
      () async {
        if (guest) {
          ProfileStore.instance.saveProfile(
            profile(token: 'expired', role: 'guest'),
          );
        }
        await submit(
          MockClient((request) async {
            expect(request.headers.containsKey('Authorization'), isFalse);
            expect(
              jsonDecode(request.body)['reporter']['reporterType'],
              'guest',
            );
            return accepted();
          }),
        );
      },
    );
  }

  test('registered profile without token cannot submit as guest', () async {
    ProfileStore.instance.saveProfile(profile());
    await expectLater(
      submit(
        MockClient((_) async {
          fail('No request should be sent');
        }),
      ),
      throwsA(
        isA<SelfReportSubmissionException>().having(
          (e) => e.statusCode,
          'status',
          401,
        ),
      ),
    );
  });

  for (final suffix in ['', '/', '/api', '/api/']) {
    test('normalizes base suffix $suffix and accepts HTTP 200', () async {
      await submit(
        MockClient((request) async {
          expect(
            request.url.toString(),
            'http://localhost:8000/api/mobile/self-reports',
          );
          return accepted(200);
        }),
        'http://localhost:8000$suffix',
      );
    });
  }

  for (final status in [401, 422, 500]) {
    test('HTTP $status fails without retry', () async {
      var calls = 0;
      await expectLater(
        submit(
          MockClient((_) async {
            calls++;
            return http.Response('{}', status);
          }),
        ),
        throwsA(
          isA<SelfReportSubmissionException>().having(
            (e) => e.statusCode,
            'status',
            status,
          ),
        ),
      );
      expect(calls, 1);
    });
  }

  test('malformed success is not treated as accepted', () async {
    await expectLater(
      submit(MockClient((_) async => http.Response('{}', 201))),
      throwsFormatException,
    );
  });
}
