import 'dart:developer';

import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  /// 내 프로필 조회
  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get(Apis.userMe);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      log('[UserService] 프로필 조회 실패: $e');
      rethrow;
    }
  }

  /// 내 신고 목록 조회
  Future<List<dynamic>> getMyReports() async {
    try {
      final response = await _apiClient.dio.get('${Apis.reports}/me');
      return response.data as List<dynamic>;
    } catch (e) {
      log('[UserService] 내 신고 조회 실패: $e');
      rethrow;
    }
  }

  /// 알림 설정 수정
  Future<void> updateSettings({
    bool? nearbyDangerAlert,
    bool? emergencyAlert,
  }) async {
    try {
      await _apiClient.dio.patch(
        Apis.userSettings,
        data: {
          if (nearbyDangerAlert != null)
            'nearbyDangerAlert': nearbyDangerAlert,
          if (emergencyAlert != null) 'emergencyAlert': emergencyAlert,
        },
      );
      log('[UserService] 알림 설정 수정 성공');
    } catch (e) {
      log('[UserService] 알림 설정 수정 실패: $e');
      rethrow;
    }
  }
}
