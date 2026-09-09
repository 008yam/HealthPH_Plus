import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

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

  String get backgroundAsset {
    switch (this) {
      case HealthPhVisualMode.appDefault:
        return "assets/images/HealthPhPlusDefaultBackground.png";
      case HealthPhVisualMode.light:
        return "assets/images/HealthPhPlusLight.png";
      case HealthPhVisualMode.grey:
        return "assets/images/HealthPhPlusGreyBackground.png";
      case HealthPhVisualMode.dark:
        return "assets/images/HealthPhPlusDarkBackground.png";
    }
  }

  Color get accentColor {
    switch (this) {
      case HealthPhVisualMode.appDefault:
        return const Color(0xFF31459B);
      case HealthPhVisualMode.light:
        return const Color(0xFF2F80ED);
      case HealthPhVisualMode.grey:
        return const Color(0xFF607080);
      case HealthPhVisualMode.dark:
        return const Color(0xFF72A7FF);
    }
  }

  String get description {
    switch (this) {
      case HealthPhVisualMode.appDefault:
        return "HealthPH+ blue and gold";
      case HealthPhVisualMode.light:
        return "Bright clinical layout";
      case HealthPhVisualMode.grey:
        return "Soft neutral contrast";
      case HealthPhVisualMode.dark:
        return "Low-light dashboard style";
    }
  }

  Color get backgroundOverlayColor {
    switch (this) {
      case HealthPhVisualMode.appDefault:
        return Colors.white.withValues(alpha: 0.08);
      case HealthPhVisualMode.light:
        return Colors.white.withValues(alpha: 0.12);
      case HealthPhVisualMode.grey:
        return Colors.white.withValues(alpha: 0.10);
      case HealthPhVisualMode.dark:
        return Colors.black.withValues(alpha: 0.18);
    }
  }

  Alignment get backgroundAlignment {
    switch (this) {
      case HealthPhVisualMode.appDefault:
      case HealthPhVisualMode.light:
      case HealthPhVisualMode.grey:
      case HealthPhVisualMode.dark:
        return Alignment.topCenter;
    }
  }

  Color get onBackground {
    switch (this) {
      case HealthPhVisualMode.dark:
        return Colors.white;
      case HealthPhVisualMode.appDefault:
      case HealthPhVisualMode.light:
      case HealthPhVisualMode.grey:
        return const Color(0xFF172033);
    }
  }

  Color get onBackgroundMuted {
    switch (this) {
      case HealthPhVisualMode.dark:
        return const Color(0xFFE6EEFF);
      case HealthPhVisualMode.appDefault:
      case HealthPhVisualMode.light:
      case HealthPhVisualMode.grey:
        return const Color(0xFF4B5875);
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
