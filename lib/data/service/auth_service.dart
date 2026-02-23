import 'dart:developer';

import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:dio/dio.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageRepository _secureStorage = SecureStorageRepository();

  /// POST google 서버에서 받은 accessToken으로 서비스 accessToken 발급
 // TODO : 서버 스웨그 보고 맞춰서 수정
//   Future<TokenResponse> getGoogleAccessToken(
//       String authCode, String name) async {
//     try {
//       final response = await _apiClient.dio.post(
//         options: Options(
//           extra: {'skipAuthToken': true}, //토큰 해제
//         ),
//         Apis.getGoogleAccessToken,
//         queryParameters: {
//           'accessToken': authCode,
//         },
//       );
//       if (response.statusCode == 200) {
//         // BaseResponse
//         final baseResponse = BaseResponse<TokenResponse>.fromJson(
//           response.data as Map<String, dynamic>,
//               (contentJson) =>
//               TokenResponse.fromJson(contentJson as Map<String, dynamic>),
//         );
//
// // AccessToken 저장 로직 수정
//         final tokenResponse = baseResponse.content;
//
//         if (tokenResponse != null) {
//           await _secureStorage.saveAccessToken(tokenResponse.accessToken);
//           await _secureStorage.saveRefreshToken(tokenResponse.refreshToken);
//
//           log("accessToken ${tokenResponse.accessToken} refreshtoken ${tokenResponse.refreshToken}");
//         }
//
//         return tokenResponse;
//       } else {
//         throw Exception(
//             'Failed to send verification code ${response.data.toString()}');
//       }
//     } on DioException catch (e) {
//       throw Exception('Error: ${e.response?.data.toString() ?? e.message}');
//     }
//   }
}