import 'package:ansim_app/data/service/user_service.dart';
import 'package:ansim_app/screens/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class MyPageViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = true;
  String? _name;
  String? _email;
  String? _profileImage;
  String? _address;
  bool _nearbyDangerAlert = true;
  bool _emergencyAlert = true;
  List<Map<String, dynamic>> _myReports = [];

  bool get isLoading => _isLoading;
  String get name => _name ?? '사용자';
  String get email => _email ?? '';
  String? get profileImage => _profileImage;
  String get address => _address ?? '주소 미설정';
  bool get nearbyDangerAlert => _nearbyDangerAlert;
  bool get emergencyAlert => _emergencyAlert;
  List<Map<String, dynamic>> get myReports => _myReports;

  MyPageViewModel() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _userService.getMyProfile(),
        _userService.getMyReports(),
      ]);

      final profile = results[0] as Map<String, dynamic>;
      _name = profile['name'] as String?;
      _email = profile['email'] as String?;
      _profileImage = profile['profileImage'] as String?;
      _address = profile['address'] as String?;

      final settings = profile['settings'] as Map<String, dynamic>?;
      if (settings != null) {
        _nearbyDangerAlert = settings['nearbyDangerAlert'] as bool? ?? true;
        _emergencyAlert = settings['emergencyAlert'] as bool? ?? true;
      }

      final reports = results[1] as List<dynamic>;
      _myReports = reports
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('프로필 조회 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? address}) async {
    try {
      await _userService.updateProfile(name: name, address: address);
      if (name != null) _name = name;
      if (address != null) _address = address;
      notifyListeners();
    } catch (e) {
      debugPrint('프로필 수정 실패: $e');
      rethrow;
    }
  }

  Future<void> toggleNearbyDangerAlert(bool value) async {
    _nearbyDangerAlert = value;
    notifyListeners();
    try {
      await _userService.updateSettings(nearbyDangerAlert: value);
    } catch (e) {
      _nearbyDangerAlert = !value;
      notifyListeners();
      debugPrint('알림 설정 변경 실패: $e');
    }
  }

  Future<void> toggleEmergencyAlert(bool value) async {
    _emergencyAlert = value;
    notifyListeners();
    try {
      await _userService.updateSettings(emergencyAlert: value);
    } catch (e) {
      _emergencyAlert = !value;
      notifyListeners();
      debugPrint('알림 설정 변경 실패: $e');
    }
  }

  Future<void> logout() async {
    GetIt.I<AuthProvider>().logout();
  }
}
