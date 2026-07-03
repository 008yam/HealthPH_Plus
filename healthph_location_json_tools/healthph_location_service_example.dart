import 'dart:convert';
import 'package:flutter/services.dart';

class LocationDataService {
  Future<List<dynamic>> loadRegions() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations/regions.json',
    );
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<List<dynamic>> loadProvinces() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations/provinces.json',
    );
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<List<dynamic>> loadCitiesMunicipalities() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations/cities_municipalities.json',
    );
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<List<dynamic>> loadBarangaysByRegion(String regionCode) async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations/barangays_by_region/$regionCode.json',
    );
    return jsonDecode(jsonString) as List<dynamic>;
  }

  Future<List<dynamic>> loadFullHierarchy() async {
    final jsonString = await rootBundle.loadString(
      'assets/data/locations/philippines_full.json',
    );
    return jsonDecode(jsonString) as List<dynamic>;
  }
}
