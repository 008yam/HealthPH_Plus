import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingResult {
  final double latitude;
  final double longitude;
  final String displayName;

  const GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

class GeocodingService {
  GeocodingService._();

  static final GeocodingService instance = GeocodingService._();

  final Map<String, GeocodingResult> _cache = {};
  DateTime? _lastRequestAt;

  Future<GeocodingResult?> geocodePhilippinesAddress({
    required String barangay,
    required String city,
    required String province,
  }) async {
    final query = [
      barangay,
      city,
      province,
      "Philippines",
    ].where((part) => part.trim().isNotEmpty).join(", ");

    final cached = _cache[query];
    if (cached != null) return cached;

    final lastRequesetAt = _lastRequestAt;
    if (lastRequesetAt != null) {
      final elapsed = DateTime.now().difference(lastRequesetAt);
      if (elapsed < const Duration(seconds: 1)) {
        await Future.delayed(const Duration(seconds: 1) - elapsed);
      }
    }

    _lastRequestAt = DateTime.now();

final uri = Uri.https(
  "nominatim.openstreetmap.org",
  "/search",
  {
    "format": "jsonv2",
    "q": query,
    "countrycodes": "ph",
    "limit": "1",
    "addressdetails": "1",
    },
  );

    final response = await http.get(
      uri,
      headers: const {
        "Accept": "application/json",
        "User-Agent": "HealthPHPlus/1.0 (com.healthphplus.app)",
      },
    );
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body) as List<dynamic>;
    if (decoded.isEmpty) return null;

    final result = Map<String, dynamic>.from(decoded.first as Map);
    final latitude = double.tryParse(result["lat"]?.toString() ?? "");
    final longitude = double.tryParse(result["lon"]?.toString() ?? "" );

    if (latitude == null || longitude == null) return null;

    final geocoded = GeocodingResult(
      latitude: latitude,
      longitude: longitude,
      displayName: result["display_name"]?.toString() ?? query,
      );

    _cache[query] = geocoded;
    return geocoded;
  }
}