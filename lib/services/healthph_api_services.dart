import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/app_taxonomy.dart';
import 'profile_store.dart';
import 'self_report_store.dart';

class SelfReportSubmissionException implements Exception {
  final String message;
  final int? statusCode;

  const SelfReportSubmissionException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SelfReportSubmissionResult {
  final String id;
  final String status;
  final String? analyticsEntryId;

  const SelfReportSubmissionResult({
    required this.id,
    required this.status,
    this.analyticsEntryId,
  });

  factory SelfReportSubmissionResult.fromJson(Map<String, dynamic> json) {
    final item = json['item'];
    if (item is! Map ||
        item['id'] is! String ||
        (item['id'] as String).isEmpty ||
        item['status'] != 'submitted') {
      throw const FormatException('Invalid self-report submission response');
    }
    final analyticsId = json['analyticsEntryId'] ?? item['analyticsEntryId'];
    return SelfReportSubmissionResult(
      id: item['id'] as String,
      status: item['status'] as String,
      analyticsEntryId: analyticsId is String ? analyticsId : null,
    );
  }
}

class HealthPhApiService {
  final String baseUrl;
  final http.Client? _client;

  HealthPhApiService({required this.baseUrl, http.Client? client})
    : _client = client;

  Future<Map<String, dynamic>> fetchDiseasePoints() async {
    final response = await http.get(Uri.parse('$baseUrl/api/points/disease'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to loaod disease points');
  }

  Future<SelfReportSubmissionResult> submitSelfReport({
    required SelfReport report,
    required String regionName,
    String? provinceCode,
    String? cityCode,
    String? barangayCode,
  }) async {
    final profile = ProfileStore.instance.profile;
    final isGuest =
        profile == null ||
        AppTaxonomy.isGuestRole(profile.roleId) ||
        profile.email == AppTaxonomy.guestEmail;

    final token = profile?.accessToken?.trim() ?? '';
    if (!isGuest && token.isEmpty) {
      throw const SelfReportSubmissionException(
        'Please sign in again before submitting your report.',
        statusCode: 401,
      );
    }
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (!isGuest) 'Authorization': 'Bearer $token',
    };

    // Explicit request fields exclude all server-owned analytics/language data.
    final payload = {
      "reporter": {
        "userId": isGuest ? null : profile.id,
        "reporterType": isGuest ? "guest" : "registered",
        "roleId": isGuest ? "guest" : "user",
        "roleLabel": isGuest ? "Guest" : "User",
        "fullName": isGuest ? null : profile.fullName,
        "email": isGuest ? null : profile.email,
      },
      "location": {
        "regionCode": report.region,
        "regionName": regionName,
        "provinceCode": provinceCode,
        "provinceName": report.province,
        "cityCode": cityCode,
        "cityName": report.city,
        "barangayCode": barangayCode,
        "barangayName": report.barangay,
        "latitude": report.latitude,
        "longitude": report.longitude,
        "geocodedAddress": report.geocodedAddress,
        "pinAccuracy": report.hasCoordinates ? "geocoded" : "region_estimate",
      },
      "symptomIds": report.symptomIds,
      "symptomLabels": report.symptoms,
      "possibleConditionId": report.possibleConditionId,
      "possibleConditionLabel": report.possibleCondition,
      "notes": report.notes,
      "source": "mobile_self_report",
      "createdAt": report.createdAt.toUtc().toIso8601String(),
    };

    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (path.endsWith('/api')) path = path.substring(0, path.length - 4);
    final uri = base.replace(
      path: '$path/api/mobile/self-reports',
      query: null,
      fragment: null,
    );
    final post = _client?.post ?? http.post;
    if (kDebugMode) debugPrint('SELF REPORT URL: $uri');
    final response = await post(
      uri,
      headers: headers,
      body: jsonEncode(payload),
    ).timeout(const Duration(seconds: 30));
    // Temporary diagnostics; response bodies may contain private report data.
    if (kDebugMode) {
      debugPrint('STATUS: ${response.statusCode}');
      debugPrint('BODY: ${response.body}');
    }

    if (response.statusCode == 401) {
      throw const SelfReportSubmissionException(
        'Your session has expired. Please sign in again.',
        statusCode: 401,
      );
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw SelfReportSubmissionException(
        'The server did not accept your report. Please review your details and try again.',
        statusCode: response.statusCode,
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid self-report submission response');
    }
    return SelfReportSubmissionResult.fromJson(decoded);
  }

  Future<List<dynamic>> fetchSelfReportMapPins() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/mobile/self-reports/map-pins"),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception('Failed to load self-report map pings');
  }

  Future<List<Map<String, dynamic>>> fetchMySelfReports({
    String? userId,
    String? email,
  }) async {
    final query = <String, String>{};
    final cleanedUserId = userId?.trim();
    final cleanedEmail = email?.trim();

    if (cleanedUserId != null && cleanedUserId.isNotEmpty) {
      query["user_id"] = cleanedUserId;
    } else if (cleanedEmail != null && cleanedEmail.isNotEmpty) {
      query["email"] = cleanedEmail;
    }

    if (query.isEmpty) {
      throw ArgumentError("A user id or email is required.");
    }

    final uri = Uri.parse(
      "$baseUrl/api/mobile/self-reports/mine",
    ).replace(queryParameters: query);

    final response = await http.get(uri).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      return [];
    }

    throw Exception(
      "Failed to load your self-reports "
      "(${response.statusCode}): ${response.body}",
    );
  }

  Future<List<Map<String, dynamic>>> fetchHealthLiteracyContent() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/health-literacy/mobile'))
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map || decoded["items"] is! List) {
        throw const FormatException(
          "Health literacy response has no items array",
        );
      }
      final items = decoded["items"] as List;

      return items
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw Exception(
      "Failed to load health literacy content "
      "(${response.statusCode}): ${response.body}",
    );
  }

  UserProfile _profileFromJson(
    Map<String, dynamic> json, {
    String? accessToken,
  }) {
    return UserProfile(
      id: json["id"] as String?,
      fullName: json["fullName"] as String? ?? "",
      email: json["email"] as String? ?? "",
      accessToken: accessToken ?? json["accessToken"]?.toString(),
      pinConfigured: json["pinConfigured"] as bool? ?? false,
      roleId: json["roleId"] as String? ?? "user",
      role: json["roleLabel"] as String? ?? json["role"] as String? ?? "User",
      language: json["language"] as String? ?? "English",
      regionCode: json["regionCode"] as String? ?? "",
      regionLabel: json["regionLabel"] as String? ?? "",
      province: json["province"] as String? ?? "",
      city: json["city"] as String? ?? "",
      barangay: json["barangay"] as String? ?? "",
    );
  }

  Future<UserProfile> registerMobileUser(
    UserProfile profile,
    String password,
  ) async {
    final payload = {
      "fullName": profile.fullName,
      "email": profile.email,
      "password": password,
      "roleId": "user",
      "roleLabel": "User",
      "language": profile.language,
      "regionCode": profile.regionCode,
      "regionLabel": profile.regionLabel,
      "province": profile.province,
      "city": profile.city,
      "barangay": profile.barangay,
      "source": "mobile_registration",
    };

    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/users"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception(
        "Failed to save mobile user to MongoDB: ${response.body}",
      );
    }

    return _profileFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<UserProfile> loginMobileUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/users/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to login: ${response.body}");
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final token = decoded["access_token"]?.toString();
    final userPayload = decoded["user"];

    if (userPayload is Map) {
      return _profileFromJson(
        Map<String, dynamic>.from(userPayload),
        accessToken: token,
      );
    }

    return _profileFromJson(decoded);
  }

  Future<void> setMobileUserPin({
    required String userId,
    required String pin,
    required String currentPassword,
    required String? accessToken,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/api/mobile/users/$userId/pin"),
      headers: _authenticatedHeaders(accessToken),
      body: jsonEncode({"pin": pin, "currentPassword": currentPassword}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to set Pin: ${response.body}");
    }
  }

  Future<UserProfile> verifyMobileUserPin({
    required String userId,
    required String pin,
    required String? accessToken,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/users/$userId/pin/verify"),
      headers: _authenticatedHeaders(accessToken),
      body: jsonEncode({"pin": pin}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to verify PIN: ${response.body}");
    }

    return _profileFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<UserProfile> updatedMobileUserLanguage({
    required String userId,
    required String language,
    required String? accessToken,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/api/mobile/users/$userId/language"),
      headers: _authenticatedHeaders(accessToken),
      body: jsonEncode({"language": language}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update language: ${response.body}");
    }

    return _profileFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<int> fetchMobileUsersCount() async {
    final response = await http
        .get(Uri.parse("$baseUrl/api/mobile/users/count"))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return (decoded["count"] as num?)?.toInt() ?? 0;
    }

    throw Exception(
      "Failed to load mobile users count (${response.statusCode}): ${response.body}",
    );
  }

  Map<String, String> _authenticatedHeaders(String? accessToken) {
    final token = accessToken?.trim() ?? "";
    if (token.isEmpty) {
      throw StateError("A mobile access token is required.");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
