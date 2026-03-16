import 'dart:developer';

import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/token_response.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageRepository _secureStorage = SecureStorageRepository();

  /// POST google 서버에서 받은 accessToken으로 서비스 accessToken 발급

  Future<TokenResponse> getGoogleAccessToken(String authCode, String name) async {
    try {
      final response = await _apiClient.dio.post(
        Apis.getGoogleAccessToken,
        data: {
          'idToken': authCode,
        },
        options: Options(
          extra: {'skipAuthToken': true}, // 인증 토큰 제외 설정
        ),
      );

      if (response.statusCode == 200) {
        // JSON 데이터를 TokenResponse 객체로 변환
        final tokenResponse = TokenResponse.fromJson(response.data as Map<String, dynamic>);

        // SecureStorage에 저장
        await _secureStorage.saveAccessToken(tokenResponse.accessToken);
        await _secureStorage.saveRefreshToken(tokenResponse.refreshToken);

        log("accessToken ${tokenResponse.accessToken} refreshtoken ${tokenResponse.refreshToken}");
        return tokenResponse;
      } else {
        throw Exception('Failed to send verification code: ${response.data.toString()}');
      }
    } on DioException catch (e) {
      // Dio 관련 에러 처리
      throw Exception('Error: ${e.response?.data.toString() ?? e.message}');
    } catch (e) {
      // 기타 런타임 에러 처리
      throw Exception('Unknown error: $e');
    }
  }
}

