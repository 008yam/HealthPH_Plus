import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:healthphplus/services/api_config.dart';
import 'package:healthphplus/services/sentiment_survey_service.dart';
import 'package:healthphplus/services/weather_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'backend routing follows launch settings with single-server fallback',
    () {
      const primary = String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000',
      );
      const sentiment = String.fromEnvironment(
        'SENTIMENT_API_BASE_URL',
        defaultValue: primary,
      );
      const environmental = String.fromEnvironment(
        'ENVIRONMENTAL_API_BASE_URL',
        defaultValue: primary,
      );
      expect(ApiConfig.baseUrl, primary);
      expect(ApiConfig.sentimentBaseUrl, sentiment);
      expect(WeatherService().baseUrl, environmental);
    },
  );

  for (final base in [
    'http://junior.test:8000',
    'http://junior.test:8000/api/',
  ]) {
    test('survey listing uses only the configured backend: $base', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(
          request.url.toString(),
          'http://junior.test:8000/api/sentiment-pulse/public-surveys?platform=mobile',
        );
        expect(request.headers['Accept'], 'application/json');
        return http.Response('[{"id":"SUR00001","title":"Example"}]', 200);
      });
      final surveys = await SentimentSurveyService(
        baseUrl: base,
        client: client,
      ).fetchPublicSurveys();
      expect(surveys.single.id, 'SUR00001');
      client.close();
    });
  }

  for (final status in [200, 201]) {
    test(
      'survey submission reuses the mobile token and accepts $status',
      () async {
        var requests = 0;
        final client = MockClient((request) async {
          requests++;
          expect(request.method, 'POST');
          expect(
            request.url.toString(),
            'http://junior.test:8000/api/sentiment-pulse/public-surveys/SUR00001/responses',
          );
          expect(request.headers['Authorization'], 'Bearer mobile-token');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['answers'], {'Q1': 'Yes', 'Q2': 5});
          expect(body['platform'], 'mobile');
          expect(body.containsKey('language'), isFalse);
          expect(body.containsKey('analyticsEntryId'), isFalse);
          return http.Response('{"message":"saved"}', status);
        });
        await SentimentSurveyService(
          baseUrl: 'http://junior.test:8000/api/',
          client: client,
        ).submitSurveyResponse(
          surveyId: 'SUR00001',
          answers: {'Q1': 'Yes', 'Q2': 5},
          userId: 'MUSER-000004',
          accessToken: 'mobile-token',
        );
        expect(requests, 1);
        client.close();
      },
    );
  }

  test(
    'guest survey omits Authorization; rejected requests are not retried',
    () async {
      var requests = 0;
      final client = MockClient((request) async {
        requests++;
        expect(request.headers.containsKey('Authorization'), isFalse);
        return http.Response('private server details', 401);
      });
      await expectLater(
        SentimentSurveyService(
          baseUrl: 'http://junior.test:8000',
          client: client,
        ).submitSurveyResponse(surveyId: 'SUR00001', answers: {'Q1': 'Yes'}),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'safe error',
            'Exception: Failed to submit survey response: HTTP 401',
          ),
        ),
      );
      expect(requests, 1);
      client.close();
    },
  );
}
