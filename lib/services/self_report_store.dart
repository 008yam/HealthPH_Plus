import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class SelfReport {
  final String region;
  final String province;
  final String city;
  final String barangay;
  final List<String> symptoms;
  final String possibleCondition;
  final String notes;
  final DateTime createdAt;

  const SelfReport({
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.symptoms,
    required this.possibleCondition,
    required this.notes,
    required this.createdAt,
  });

  String get locationLabel => "$barangay, $city, $province";
}

class SelfReportStore extends ChangeNotifier {
  SelfReportStore._();

  static final SelfReportStore instance = SelfReportStore._();

  final List<SelfReport> _reports = [];

  List<SelfReport> get reports => List.unmodifiable(_reports);

  static final Map<String, LatLng> regionCenters = {
    "NCR": const LatLng(14.5995, 120.9842),
    "I": const LatLng(16.0832, 120.6199),
    "II": const LatLng(17.6132, 121.7270),
    "III": const LatLng(15.4828, 120.7120),
    "IVA": const LatLng(14.1008, 121.0794),
    "V": const LatLng(13.6218, 123.1948),
    "VI": const LatLng(11.0050, 122.5373),
    "VII": const LatLng(10.3157, 123.8854),
    "VIII": const LatLng(11.2433, 125.0046),
    "IX": const LatLng(7.8383, 123.2967),
    "X": const LatLng(8.4542, 124.6319),
    "XI": const LatLng(7.1907, 125.4553),
    "XII": const LatLng(6.2707, 124.6857),
    "XIII": const LatLng(8.9475, 125.5406),
    "CAR": const LatLng(16.4023, 120.5960),
    "BARMM": const LatLng(7.2167, 124.2500),
  };

  void addReport(SelfReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  List<Map<String, dynamic>> get mapReports {
    return _reports.map((report) {
      final point = regionCenters[report.region] ?? regionCenters["NCR"]!;

      return {
        "name": report.locationLabel,
        "disease": report.possibleCondition,
        "category": "Self-reported respiratory symptoms",
        "reports": 1,
        "updated": "Self-reported today",
        "lat": point.latitude,
        "lng": point.longitude,
        "tags": report.symptoms,
        "source": "selfReport",
      };
    }).toList();
  }
}
