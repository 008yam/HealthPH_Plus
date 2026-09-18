import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mobile_alert.dart';

class MobileAlertAuthenticationException implements Exception {
  final String message;

  const MobileAlertAuthenticationException(this.message);

  @override
  String toString() => message;
}

class MobileAlertService {
  final String baseUrl;

  const MobileAlertService({required this.baseUrl});

  Future<MobileAlertsPage> fetchAlerts({
    int limit = 20,
    String? cursor,
    String? accessToken,
  }) async {
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const MobileAlertAuthenticationException(
        "Sign in with a registered account to view alerts.",
      );
    }

    final query = <String, String>{"limit": limit.clamp(1, 100).toString()};

    if (cursor != null && cursor.trim().isNotEmpty) {
      query["cursor"] = cursor.trim();
    }

    final headers = <String, String>{"Accept": "application/json"};

    headers["Authorization"] = "Bearer ${accessToken.trim()}";

    final uri = Uri.parse(
      "$baseUrl/api/mobile/alerts",
    ).replace(queryParameters: query);

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      return MobileAlertsPage.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    if (response.statusCode == 401) {
      throw const MobileAlertAuthenticationException(
        "Your session has expired. Please sign in again.",
      );
    }

    throw Exception(
      "Failed to load mobile alerts (${response.statusCode}): ${response.body}",
    );
  }

  Future<MobileAlert> fetchAlert({
    required String alertId,
    required String? accessToken,
  }) async {
    final response = await http
        .get(
          Uri.parse("$baseUrl/api/mobile/alerts/$alertId"),
          headers: _authenticatedHeaders(accessToken),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return MobileAlert.fromJson(
        Map<String, dynamic>.from(decoded["item"] as Map),
      );
    }

    _throwForResponse(response);
  }

  Future<MobileAlertReadResult> markAlertRead({
    required String alertId,
    required String? accessToken,
  }) async {
    final response = await http
        .patch(
          Uri.parse("$baseUrl/api/mobile/alerts/$alertId/read"),
          headers: _authenticatedHeaders(accessToken),
          body: "{}",
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      return MobileAlertReadResult.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }

    _throwForResponse(response);
  }

  Map<String, String> _authenticatedHeaders(String? accessToken) {
    final token = accessToken?.trim() ?? "";
    if (token.isEmpty) {
      throw const MobileAlertAuthenticationException(
        "Sign in with a registered account to view alerts.",
      );
    }

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  Never _throwForResponse(http.Response response) {
    if (response.statusCode == 401) {
      throw const MobileAlertAuthenticationException(
        "Your session has expired. Please sign in again.",
      );
    }

    throw Exception(
      "Mobile alert request failed (${response.statusCode}): ${response.body}",
    );
  }
}
