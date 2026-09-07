import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/app_taxonomy.dart';
import 'profile_store.dart';
import 'self_report_store.dart';

class HealthPhApiService {
  final String baseUrl;

  HealthPhApiService({required this.baseUrl});

  Future<Map<String, dynamic>> fetchDiseasePoints() async {
    final response = await http.get(Uri.parse('$baseUrl/api/points/disease'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Failed to loaod disease points');
  }

  Future<void> submitSelfReport({
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

    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(("healhtph_selected_language"));

    final language = profile?.language.isNotEmpty == true
        ? profile!.language
        : savedLanguage?.isNotEmpty == true
            ? savedLanguage!
            : "English";

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
      "language": language,
      "notes": report.notes,
      "source": "mobile_self_report",
      "createdAt": report.createdAt.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse("$baseUrl/api/mobile/self-reports"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to sync self-report to MongoDB");
    }
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

  Future<List<Map<String, dynamic>>> fetchHealthLiteracyContent() async {
    final response = await http
        .get(Uri.parse('$baseUrl/api/health-literacy/mobile'))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> items;
      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map && decoded["items"] is List) {
        items = decoded["items"] as List;
      } else {
        items = [];
      }

      return items
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw Exception(
      "Failed to load health literacy content "
      "(${response.statusCode}): ${response.body}",
    );
  }

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json["id"] as String?,
      fullName: json["fullName"] as String? ?? "",
      email: json["email"] as String? ?? "",
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

    return _profileFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<UserProfile> updatedMobileUserLanguage({
    required String userId,
    required String language,
  }) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/api/mobile/users/$userId/language"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"language": language}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to update language: ${response.body}");
    }

    return _profileFromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
