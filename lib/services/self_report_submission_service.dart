import 'package:flutter/foundation.dart';

import '../data/app_taxonomy.dart';
import 'api_config.dart';
import 'geocoding_service.dart';
import 'healthph_api_services.dart';
import 'location_data_services.dart';
import 'self_report_database.dart';
import 'self_report_store.dart';

class SelfReportSubmissionOutcome {
  final SelfReport report;
  final AppOption condition;
  final bool cachedLocally;

  const SelfReportSubmissionOutcome({
    required this.report,
    required this.condition,
    required this.cachedLocally,
  });
}

class SelfReportSubmissionService {
  final HealthPhApiService _api;
  final GeocodingService _geocoding;
  final SelfReportDatabase _database;
  final SelfReportStore _store;

  SelfReportSubmissionService({
    HealthPhApiService? api,
    GeocodingService? geocoding,
    SelfReportDatabase? database,
    SelfReportStore? store,
  }) : _api = api ?? HealthPhApiService(baseUrl: ApiConfig.baseUrl),
       _geocoding = geocoding ?? GeocodingService.instance,
       _database = database ?? SelfReportDatabase.instance,
       _store = store ?? SelfReportStore.instance;

  Future<SelfReportSubmissionOutcome> submit({
    required LocationOption region,
    required LocationOption? province,
    required LocationOption city,
    required LocationOption barangay,
    required List<String> symptomIds,
    required AppOption condition,
    required String notes,
  }) async {
    final provinceName = province?.name ?? region.name;

    final geocoded = await _geocoding.geocodePhilippinesAddress(
      barangay: barangay.name,
      city: city.name,
      province: provinceName,
    );

    final report = SelfReport(
      region: region.code,
      province: provinceName,
      city: city.name,
      barangay: barangay.name,
      latitude: geocoded?.latitude,
      longitude: geocoded?.longitude,
      geocodedAddress: geocoded?.displayName,
      symptomIds: List.unmodifiable(symptomIds),
      symptoms: AppTaxonomy.labelsFor(AppTaxonomy.symptoms, symptomIds),
      possibleConditionId: condition.id,
      possibleCondition: condition.label,
      notes: notes,
      createdAt: DateTime.now(),
    );

    await _api.submitSelfReport(
      report: report,
      regionName: region.name,
      provinceCode: province?.code,
      cityCode: city.code,
      barangayCode: barangay.code,
    );

    _store.addReport(report);

    var cachedLocally = true;

    try {
      await _database.insertReport(report);
    } catch (error) {
      cachedLocally = false;
      debugPrint('Report accepted; local cache could not be saved: $error');
    }

    return SelfReportSubmissionOutcome(
      report: report,
      condition: condition,
      cachedLocally: cachedLocally,
    );
  }
}
