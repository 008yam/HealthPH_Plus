import 'dart:convert';
import 'package:flutter/services.dart';

class LocationOption {
  final String code;
  final String name;
  final String label;

  const LocationOption({
    required this.code,
    required this.name,
    required this.label,
  });

  @override
  String toString() => label;
}

class LocationDataService {
  LocationDataService._();

  static final LocationDataService instance = LocationDataService._();

  List<Map<String, dynamic>> _regions = [];
  bool _isLoaded = false;

  Future<void> load() async {
    if (_isLoaded) return;

    final jsonString = await rootBundle.loadString(
      'assets/data/locations/philippines_full.json',
    );

    final decoded = jsonDecode(jsonString) as List<dynamic>;

    _regions = decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    _isLoaded = true;
  }

  List<LocationOption> get regions {
    return _regions.map((region) {
      final name = region["name"].toString();
      final regionName = region["regionName"]?.toString() ?? name;

      return LocationOption(
        code: region["code"].toString(),
        name: name,
        label: regionName == name ? name : "$regionName - $name",
      );
    }).toList();
  }

  List<LocationOption> provincesForRegion(String? regionCode) {
    if (regionCode == null) return [];

    final region = _findByCode(_regions, regionCode);
    final provinces = List<Map<String, dynamic>>.from(
      region?["provinces"] ?? [],
    );

    return provinces.map((province) {
      return LocationOption(
        code: province["code"].toString(),
        name: province["name"].toString(),
        label: province["name"].toString(),
      );
    }).toList();
  }

  List<LocationOption> citiesForProvince(
    String? regionCode,
    String? provinceCode,
  ) {
    if (regionCode == null || provinceCode == null) return [];

    final region = _findByCode(_regions, regionCode);
    final provinces = List<Map<String, dynamic>>.from(
      region?["provinces"] ?? [],
    );
    final province = _findByCode(provinces, provinceCode);

    final cities = List<Map<String, dynamic>>.from(
      province?["citiesMunicipalities"] ?? [],
    );

    return cities.map((city) {
      return LocationOption(
        code: city["code"].toString(),
        name: city["name"].toString(),
        label: city["name"].toString(),
      );
    }).toList();
  }

  List<LocationOption> barangaysForCity(
    String? regionCode,
    String? provinceCode,
    String? cityCode,
  ) {
    if (regionCode == null || provinceCode == null || cityCode == null) {
      return [];
    }

    final region = _findByCode(_regions, regionCode);
    final provinces = List<Map<String, dynamic>>.from(
      region?["provinces"] ?? [],
    );
    final province = _findByCode(provinces, provinceCode);

    final cities = List<Map<String, dynamic>>.from(
      province?["citiesMunicipalities"] ?? [],
    );
    final city = _findByCode(cities, cityCode);

    final barangays = List<Map<String, dynamic>>.from(
      city?["barangays"] ?? [],
    );

    return barangays.map((barangay) {
      return LocationOption(
        code: barangay["code"].toString(),
        name: barangay["name"].toString(),
        label: barangay["name"].toString(),
      );
    }).toList();
  }

  Map<String, dynamic>? _findByCode(
    List<Map<String, dynamic>> items,
    String code,
  ) {
    for (final item in items) {
      if (item["code"].toString() == code) {
        return item;
      }
    }

    return null;
  }
}