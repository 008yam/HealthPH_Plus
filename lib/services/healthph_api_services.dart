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

    final payload = {
      "reporter": {
        "userId": null,
        "reporterType": isGuest ? "guest" : "registered",
        "roleId": profile?.roleId ?? AppTaxonomy.guestRole.id,
        "roleLabel": profile?.role ?? AppTaxonomy.guestRole.label,
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
  final response = await http.get(
    Uri.parse('$baseUrl/api/health-literacy/mobile'),
  );

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

  throw Exception("Failed to load health literacy content");
}
}
