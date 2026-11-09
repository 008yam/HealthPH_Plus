import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';

class SentimentReportingException implements Exception {
  final String message;
  final int? status;
  const SentimentReportingException(this.message, {this.status});
}

class SentimentReportingService {
  final String baseUrl;
  final http.Client _client;
  final bool _ownsClient;
  SentimentReportingService({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  Future<SentimentPulseReport> fetch({
    required String? accessToken,
    required SentimentReportFilters filters,
  }) async {
    final token = accessToken?.trim() ?? '';
    if (token.isEmpty) {
      throw const SentimentReportingException(
        'Sign in to view reporting data.',
        status: 401,
      );
    }
    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api')) path = '$path/api';
    final uri = base
        .replace(
          path: '$path/mobile/sentiment-pulse/trends',
          queryParameters: filters.toQuery(),
        )
        .removeFragment();
    if (kDebugMode) debugPrint('SENTIMENT REPORT URL: $uri');
    final response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 30));
    // Never log the token, response body, or participant information.
    if (kDebugMode) {
      debugPrint('SENTIMENT REPORT STATUS: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      final message = switch (response.statusCode) {
        400 || 422 => 'Invalid reporting filters. Review your selection.',
        401 => 'Your session has expired. Please sign in again.',
        403 => 'Reporting access denied. Check backend permissions.',
        404 => 'Report or survey unavailable. Check the backend and filters.',
        503 => 'Reporting configuration unavailable. Try again later.',
        _ => 'Unable to load reporting data. Please retry.',
      };
      // Error detail can be structured; it is not safe to display it verbatim.
      throw SentimentReportingException(message, status: response.statusCode);
    }
    final json = jsonDecode(response.body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Invalid reporting response');
    }
    return SentimentPulseReport.fromJson(json);
  }

  void dispose() {
    if (_ownsClient) _client.close();
  }
}
