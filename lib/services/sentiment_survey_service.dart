import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mobile_survey.dart';

class SentimentSurveyService {
  final String baseUrl;
  final http.Client? _client;

  SentimentSurveyService({required this.baseUrl, http.Client? client})
    : _client = client;

  Uri _surveyUrl({String? surveyId}) {
    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api')) path = '$path/api';
    final root = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '$path/sentiment-pulse/public-surveys',
    );
    if (surveyId == null) {
      return root.replace(queryParameters: {'platform': 'mobile'});
    }
    return root.replace(
      pathSegments: [...root.pathSegments, surveyId, 'responses'],
    );
  }

  Future<List<MobileSurvey>> fetchPublicSurveys() async {
    final client = _client ?? http.Client();
    late final http.Response response;
    try {
      response = await client
          .get(_surveyUrl(), headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
    } finally {
      if (_client == null) client.close();
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) => MobileSurvey.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return [];
    }

    throw Exception('Failed to load public surveys: ${response.statusCode}');
  }

  Future<void> submitSurveyResponse({
    required String surveyId,
    required Map<String, dynamic> answers,
    String? region,
    String? userId,
    String? accessToken,
    Map<String, dynamic>? userLocation,
    Map<String, dynamic>? metadata,
  }) async {
    final visitorId = await _getVisitorId();

    final payload = {
      "answers": answers,
      "platform": "mobile",
      "visitorId": visitorId,
      "userId": userId,
      "userLocation": userLocation ?? {},
      "region": region,
      "metadata": metadata ?? {},
    };

    final token = accessToken?.trim() ?? '';
    final client = _client ?? http.Client();
    late final http.Response response;
    try {
      response = await client
          .post(
            _surveyUrl(surveyId: surveyId),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));
    } finally {
      if (_client == null) client.close();
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to submit survey response: HTTP ${response.statusCode}',
      );
    }
  }

  Future<String> _getVisitorId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString("healthph_survey_visitor_id");

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final randomValue = Random().nextInt(999999).toString().padLeft(6, '0');
    final visitorId =
        "mobile-${DateTime.now().microsecondsSinceEpoch}-$randomValue";
    await prefs.setString("healthph_survey_visitor_id", visitorId);
    return visitorId;
  }
}
