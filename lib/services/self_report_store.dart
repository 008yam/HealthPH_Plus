import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class SelfReport {
  final String region;
  final String province;
  final String city;
  final String barangay;
  final List<String> symptomIds;
  final List<String> symptoms;
  final String possibleConditionId;
  final String possibleCondition;
  final String notes;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? geocodedAddress;

  const SelfReport({
    required this.region,
    required this.province,
    required this.city,
    required this.barangay,
    required this.symptomIds,
    required this.symptoms,
    required this.possibleConditionId,
    required this.possibleCondition,
    required this.notes,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.geocodedAddress,
  });

  String get locationLabel => "$barangay, $city, $province";
  String get reportedAtLabel {
    final hour = createdAt.hour.toString().padLeft(2, "0");
    final minute = createdAt.minute.toString().padLeft(2, "0");
    return "Self-reported on ${createdAt.month}/${createdAt.day}/${createdAt.year} at $hour:$minute";
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}

class SelfReportStore extends ChangeNotifier {
  SelfReportStore._();

  static final SelfReportStore instance = SelfReportStore._();

  final List<SelfReport> _reports = [];

  List<SelfReport> get reports => List.unmodifiable(_reports);

  static final Map<String, LatLng> regionCenters = {
    "010000000": const LatLng(16.0832, 120.6199), // Region I
    "020000000": const LatLng(17.6132, 121.7270), // Region II
    "030000000": const LatLng(15.4828, 120.7120), // Region III
    "040000000": const LatLng(14.1008, 121.0794), // Region IV-A
    "170000000": const LatLng(12.8797, 121.7740), // MIMAROPA
    "050000000": const LatLng(13.6218, 123.1948), // Region V
    "060000000": const LatLng(11.0050, 122.5373), // Region VI
    "070000000": const LatLng(10.3157, 123.8854), // Region VII
    "080000000": const LatLng(11.2433, 125.0046), // Region VIII
    "090000000": const LatLng(7.8383, 123.2967), // Region IX
    "100000000": const LatLng(8.4542, 124.6319), // Region X
    "110000000": const LatLng(7.1907, 125.4553), // Region XI
    "120000000": const LatLng(6.2707, 124.6857), // Region XII
    "130000000": const LatLng(14.5995, 120.9842), // NCR
    "140000000": const LatLng(16.4023, 120.5960), // CAR
    "160000000": const LatLng(8.9475, 125.5406), // Region XIII
    "150000000": const LatLng(7.2167, 124.2500), // BARMM
  };

  void addReport(SelfReport report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void replaceReports(List<SelfReport> reports) {
    _reports
      ..clear()
      ..addAll(reports);
    notifyListeners();
  }

  List<Map<String, dynamic>> get mapReports {
    return _reports.map((report) {
      final point = report.hasCoordinates
          ? LatLng(report.latitude!, report.longitude!)
          : regionCenters[report.region] ?? const LatLng(12.8787, 121.7740);

      return {
        "name": report.locationLabel,
        "diseaseId": report.possibleConditionId,
        "disease": report.possibleCondition,
        "category": "Self-reported respiratory symptoms",
        "reports": 1,
        "updated": report.reportedAtLabel,
        "lat": point.latitude,
        "lng": point.longitude,
        "tagIds": report.symptomIds,
        "tags": report.symptoms,
        "source": "selfReport",
        "pinAccuracy": report.hasCoordinates
            ? "Exact address geocoded"
            : "Region-level estimate",
        "geocodedAddress": report.geocodedAddress,
      };
    }).toList();
  }
}
