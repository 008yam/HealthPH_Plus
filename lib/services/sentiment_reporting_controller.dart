import 'package:flutter/foundation.dart';
import '../models/sentiment_pulse_report.dart';
import '../models/sentiment_report_filters.dart';
import 'profile_store.dart';
import 'sentiment_reporting_service.dart';

class SentimentReportingController extends ChangeNotifier {
  final SentimentReportingService service;
  final ProfileStore profiles;
  SentimentReportFilters filters = const SentimentReportFilters();
  SentimentPulseReport? report;
  String? error;
  bool loading = false, authenticationRequired = false;
  int _request = 0;
  bool _disposed = false;
  String? _id, _token, _region;

  SentimentReportingController(this.service, {ProfileStore? profiles})
    : profiles = profiles ?? ProfileStore.instance {
    this.profiles.addListener(_profileChanged);
    _rememberProfile();
  }
  void _rememberProfile() {
    final p = profiles.profile;
    _id = p?.id;
    _token = p?.accessToken;
    _region = p == null ? null : '${p.regionCode}|${p.regionLabel}';
  }

  void _profileChanged() {
    final p = profiles.profile;
    final region = p == null ? null : '${p.regionCode}|${p.regionLabel}';
    if (_id == p?.id && _token == p?.accessToken && _region == region) return;
    if (p == null || _id != p.id) filters = const SentimentReportFilters();
    _rememberProfile();
    refresh();
  }

  void select(SentimentReportFilters next) {
    filters = next;
    refresh();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final request = ++_request;
    final p = profiles.profile;
    report = null;
    error = null;
    loading = false;
    authenticationRequired =
        p == null ||
        p.roleId != 'user' ||
        (p.accessToken?.trim().isEmpty ?? true);
    if (authenticationRequired) {
      error = 'Sign in to view reporting data.';
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final result = await service.fetch(
        accessToken: p!.accessToken,
        filters: filters,
      );
      if (_disposed || request != _request) return;
      if (!filters.matches(result.filters) ||
          (filters.regionalRegion != null &&
              result.regional.regionCode != filters.regionalRegion)) {
        throw const FormatException('Reporting scope does not match');
      }
      report = result;
    } on SentimentReportingException catch (failure) {
      if (_disposed || request != _request) return;
      if (failure.status == 401) {
        // Prevent another request from reusing this expired session.
        profiles.clearProfile();
        error = failure.message;
        notifyListeners();
        return;
      }
      error = '${failure.message} (HTTP ${failure.status})';
    } on FormatException {
      if (_disposed || request != _request) return;
      error =
          'Incompatible reporting response. Ask for the updated backend build.';
    } catch (_) {
      if (_disposed || request != _request) return;
      error = 'Unable to load reporting data. Please retry.';
    }
    if (_disposed || request != _request) return;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_request;
    profiles.removeListener(_profileChanged);
    super.dispose();
  }
}
