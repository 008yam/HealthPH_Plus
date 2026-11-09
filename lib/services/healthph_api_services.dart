import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/app_taxonomy.dart';
import '../models/surveillance_pin.dart';
import 'profile_store.dart';
import 'self_report_store.dart';

class SelfReportAuthenticationException implements Exception {
  final String message;
  const SelfReportAuthenticationException(this.message);
  @override
  String toString() => message;
}

class SurveillanceMapException implements Exception {
  final String message;
  final int? statusCode;
  const SurveillanceMapException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class LanguageUpdateException implements Exception {
  final String message;
  final int? statusCode;

  const LanguageUpdateException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

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
        "userId": isGuest ? "GUEST" : profile.id,
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

  Future<List<SurveillancePin>> fetchSurveillanceMapPins({
    int days = 7,
    String region = 'all',
    String disease = 'all',
  }) async {
    if (days < 1 || days > 365) throw ArgumentError.value(days, 'days');
    if (disease != 'all' && !SurveillancePin.diseases.contains(disease)) {
      throw ArgumentError.value(disease, 'disease');
    }
    if (region.trim().isEmpty) throw ArgumentError.value(region, 'region');
    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api')) path = '$path/api';
    final uri = base.replace(
      path: '$path/mobile/surveillance/map-pins',
      queryParameters: {
        if (days == 1) 'hours': '24' else 'days': '$days',
        'region': region,
        'disease': disease,
      },
      fragment: '',
    );
    // Public read-only aggregation: no mobile token or raw-report fallback.
    if (kDebugMode) debugPrint('SURVEILLANCE MAP URL: $uri');
    late final http.Response response;
    try {
      response = await (_client?.get ?? http.get)(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const SurveillanceMapException(
        'The map request timed out. Check the backend connection.',
      );
    } on http.ClientException {
      throw const SurveillanceMapException(
        'Cannot reach the map backend. Check the API address and network.',
      );
    }
    if (kDebugMode) {
      debugPrint('SURVEILLANCE MAP STATUS: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      throw SurveillanceMapException(
        response.statusCode == 404
            ? 'Surveillance endpoint not found (HTTP 404). Check the backend deployment.'
            : 'The map backend returned HTTP ${response.statusCode}.',
        statusCode: response.statusCode,
      );
    }
    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['items'] is! List) {
      throw const FormatException('Surveillance response must contain items');
    }
    final result = <SurveillancePin>[];
    final ids = <String>{};
    for (final item in data['items'] as List) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid pin');
      }
      final pin = SurveillancePin.fromJson(item);
      if (!ids.add(pin.id)) {
        throw const FormatException('Duplicate surveillance pin id');
      }
      result.add(pin);
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchMySelfReports({
    required String? accessToken,
  }) async {
    final token = accessToken?.trim() ?? '';
    if (token.isEmpty) {
      throw const SelfReportAuthenticationException(
        'Please sign in again to view your self-reports.',
      );
    }
    final base = Uri.parse(baseUrl);
    var path = base.path.replaceFirst(RegExp(r'/+$'), '');
    if (!path.endsWith('/api')) path = '$path/api';
    final uri = base
        .replace(
          path: '$path/mobile/self-reports/mine',
          queryParameters: const {},
          fragment: '',
        )
        .removeFragment();
    // The backend determines ownership from the mobile JWT, not a query user ID.
    final response = await (_client?.get ?? http.get)(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 12));
    if (response.statusCode == 401) {
      throw const SelfReportAuthenticationException(
        'Your session has expired or is invalid. Please sign in again.',
      );
    }
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final items = decoded is Map<String, dynamic>
          ? decoded['items']
          : decoded;
      if (items is! List ||
          items.any((item) => item is! Map<String, dynamic>)) {
        throw const FormatException('Invalid self-report history response');
      }
      return items.cast<Map<String, dynamic>>();
    }

    throw Exception(
      "Failed to load your self-reports "
      "(${response.statusCode})",
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

    if (kDebugMode) {
      final fields = userPayload is Map ? userPayload : decoded;
      debugPrint('LOGIN HOST: ${Uri.parse(baseUrl).origin}');
      debugPrint(
        'LOGIN pinConfigured present: ${fields.containsKey("pinConfigured")}',
      );
      debugPrint('LOGIN pinConfigured: ${fields["pinConfigured"]}');
    }

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

    if (kDebugMode) {
    debugPrint('PIN SETUP HOST: ${Uri.parse(baseUrl).origin}');
    debugPrint('PIN SETUP STATUS: ${response.statusCode}');
  }

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

    if (kDebugMode) {
      debugPrint('PIN VERIFY HOST: ${Uri.parse(baseUrl).origin}');
      debugPrint('PIN VERIFY STATUS: ${response.statusCode}');
    }

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
    if (accessToken == null || accessToken.trim().isEmpty) {
      throw const LanguageUpdateException(
        'Please sign in again to save your account language.',
        statusCode: 401,
      );
    }
    final root = baseUrl.replaceFirst(RegExp(r'/+$'), '');
    final apiRoot = root.endsWith('/api') ? root : '$root/api';
    final url = Uri.parse(
      '$apiRoot/mobile/users/${Uri.encodeComponent(userId)}/language',
    );
    final client = _client ?? http.Client();
    late final http.Response response;
    try {
      response = await client
          .patch(
            url,
            headers: _authenticatedHeaders(accessToken),
            body: jsonEncode({'language': language}),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const LanguageUpdateException(
        'Saving your account language timed out. Please try again.',
      );
    } on http.ClientException {
      throw const LanguageUpdateException(
        'Could not connect to save your account language. Please try again.',
      );
    } finally {
      if (_client == null) client.close();
    }

    if (response.statusCode != 200) {
      final message = switch (response.statusCode) {
        404 || 405 =>
          'Account language saving is unavailable on this backend (HTTP ${response.statusCode}).',
        401 => 'Please sign in again to save your account language.',
        403 => 'You do not have permission to change this account language.',
        _ => 'Could not save your account language. Please try again.',
      };
      throw LanguageUpdateException(message, statusCode: response.statusCode);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        decoded['id'] != userId ||
        decoded['language'] != language) {
      throw const FormatException('Invalid language-update response');
    }
    return _profileFromJson(decoded);
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
