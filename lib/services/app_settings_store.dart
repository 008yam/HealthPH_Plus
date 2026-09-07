import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HealthPhVisualMode { appDefault, light, grey, dark }

extension HealthPhVisualModeLabel on HealthPhVisualMode {
  String get label {
    switch (this) {
      case HealthPhVisualMode.appDefault:
        return "Default";
      case HealthPhVisualMode.light:
        return "Light";
      case HealthPhVisualMode.grey:
        return "Grey";
      case HealthPhVisualMode.dark:
        return "Dark";
    }
  }
}

class AppSettingsStore extends ChangeNotifier {
  AppSettingsStore._();

  static final AppSettingsStore instance = AppSettingsStore._();

  static const _themeKey = "healthph_visual_mode";
  static const _hasPinKey = "healthph_has_pin";
  static const _pinLoginKey = "healthph_pin_login";
  static const _fingerprintLoginKey = "healthph_fingerprint_login";

  HealthPhVisualMode visualMode = HealthPhVisualMode.appDefault;
  bool hasPin = false;
  bool pinLoginEnabled = false;
  bool fingerprintLoginEnabled = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeKey);

    visualMode = HealthPhVisualMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () => HealthPhVisualMode.appDefault,
    );

    hasPin = prefs.getBool(_hasPinKey) ?? false;
    pinLoginEnabled = prefs.getBool(_pinLoginKey) ?? false;
    fingerprintLoginEnabled = prefs.getBool(_fingerprintLoginKey) ?? false;
  }

  Future<void> setVisualMode(HealthPhVisualMode mode) async {
    visualMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> markPinConfigured() async {
    hasPin = true;
    pinLoginEnabled = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasPinKey, true);
    await prefs.setBool(_pinLoginKey, true);
  }

  Future<void> setPinLoginEnabled(bool value) async {
    if (value && !hasPin) return;

    pinLoginEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pinLoginKey, value);
  }

  Future<void> setFingerprintLoginEnabled(bool value) async {
    fingerprintLoginEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_fingerprintLoginKey, value);
  }
}