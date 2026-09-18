import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'profile_store.dart';

class BiometricAuthService {
  BiometricAuthService._();

  static final BiometricAuthService instance = BiometricAuthService._();

  static const _savedProfileKey = 'healthph_biometric_profile';

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();

      return supported && canCheck && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    final available = await canUseBiometrics();
    if (!available) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'Use biometrics to sign in to HealthPH+.',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> saveProfileForBiometricLogin(UserProfile profile) async {
    await _secureStorage.write(
      key: _savedProfileKey,
      value: jsonEncode(_profileToJson(profile)),
    );

    // Remove any profile saved by the earlier SharedPreferences implementation.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedProfileKey);
  }

  Future<UserProfile?> loadSavedProfile() async {
    final rawProfile = await _secureStorage.read(key: _savedProfileKey);

    if (rawProfile == null || rawProfile.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedProfileKey);
      return null;
    }

    try {
      final decoded = jsonDecode(rawProfile);
      return _profileFromJson(Map<String, dynamic>.from(decoded as Map));
    } catch (_) {
      return null;
    }
  }

  Future<UserProfile?> unlockSavedProfile() async {
    final savedProfile = await loadSavedProfile();
    if (savedProfile == null) return null;

    final unlocked = await authenticate();
    if (!unlocked) return null;

    return savedProfile;
  }

  Future<void> clearSavedProfile() async {
    await _secureStorage.delete(key: _savedProfileKey);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedProfileKey);
  }

  Map<String, dynamic> _profileToJson(UserProfile profile) {
    return {
      'id': profile.id,
      'fullName': profile.fullName,
      'email': profile.email,
      'accessToken': profile.accessToken,
      'pinConfigured': profile.pinConfigured,
      'roleId': profile.roleId,
      'role': profile.role,
      'language': profile.language,
      'regionCode': profile.regionCode,
      'regionLabel': profile.regionLabel,
      'province': profile.province,
      'city': profile.city,
      'barangay': profile.barangay,
    };
  }

  UserProfile _profileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      accessToken: json['accessToken'] as String?,
      pinConfigured: json['pinConfigured'] as bool? ?? false,
      roleId: json['roleId'] as String? ?? 'user',
      role: json['role'] as String? ?? 'User',
      language: json['language'] as String? ?? 'English',
      regionCode: json['regionCode'] as String? ?? '',
      regionLabel: json['regionLabel'] as String? ?? '',
      province: json['province'] as String? ?? '',
      city: json['city'] as String? ?? '',
      barangay: json['barangay'] as String? ?? '',
    );
  }
}
