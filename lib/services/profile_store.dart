import 'package:flutter/foundation.dart';

class UserProfile {
  final String? id;
  final String fullName;
  final String email;
  final String roleId;
  final String role;
  final String language;
  final String regionCode;
  final String regionLabel;
  final String province;
  final String city;
  final String barangay;

  const UserProfile({
    this.id,
    required this.fullName,
    required this.email,
    required this.roleId,
    required this.role,
    required this.language,
    required this.regionCode,
    required this.regionLabel,
    required this.province,
    required this.city,
    required this.barangay,
  });


  String get locationLabel => "$barangay, $city, $province";
  bool get hasAddress =>
      regionCode.isNotEmpty && province.isNotEmpty && city.isNotEmpty && barangay.isNotEmpty;

  UserProfile copyWith({String? language}) {
    return UserProfile(
    id: id,
    fullName: fullName,
    email: email,
    roleId: roleId,
    role: role,
    language: language ?? this.language,
    regionCode: regionCode,
    regionLabel: regionLabel,
    province: province,
    city: city,
    barangay: barangay,
    );
  }
}

class ProfileStore extends ChangeNotifier{
  ProfileStore._();

  static final ProfileStore instance = ProfileStore._();

  UserProfile? _profile;

  UserProfile? get profile => _profile;
  bool get isLoggedIn => _profile != null;

  void saveProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  void updateLanguage(String language) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(language: language);
    notifyListeners();
  }
}