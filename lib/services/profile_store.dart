import 'package:flutter/foundation.dart';

class UserProfile {
  final String fullName;
  final String email;
  final String role;
  final String regionCode;
  final String regionLabel;
  final String province;
  final String city;
  final String barangay;

  const UserProfile({
    required this.fullName,
    required this.email,
    required this.role,
    required this.regionCode,
    required this.regionLabel,
    required this.province,
    required this.city,
    required this.barangay,
  });


  String get locationLabel => "$barangay, $city, $province";
  bool get hasAddress =>
      regionCode.isNotEmpty && province.isNotEmpty && city.isNotEmpty && barangay.isNotEmpty;
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
}