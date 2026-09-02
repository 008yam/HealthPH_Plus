import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mobile_survey.dart';

class SentimentSurveyService {
  final String baseUrl;

  SentimentSurveyService({required this.baseUrl});

  Future<List<MobileSurvey>> fetchPublicSurveys() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/sentiment-pulse/public-surveys?platform=mobile"))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => MobileSurvey.fromJson(Map<String, dynamic>.from(item)))
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
    Map<String, dynamic>? metadata,
  }) async {
    final visitorId = await _getVisitorId();

    final payload = {
      "answers": answers,
      "platform": "mobile",
      "visitorId": visitorId,
      "region": region,
      "metadata": metadata ?? {},
    };

    final response = await http
        .post(
          Uri.parse("$baseUrl/api/sentiment-pulse/public-surveys/$surveyId/responses"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 201) {
      throw Exception('Failed to submit survey response: ${response.body}');
  }
}

  Future<String> _getVisitorId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString("healthph_survey_visitor_id");

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final randomValue = Random().nextInt(999999).toString().padLeft(6, '0');
    final visitorId = "mobile-${DateTime.now().microsecondsSinceEpoch}-$randomValue";
    await prefs.setString("healthph_survey_visitor_id", visitorId);
    return visitorId;
  }
}