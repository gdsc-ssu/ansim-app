import 'dart:io';
import 'dart:developer';
import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/analysis_response.dart';
import 'package:dio/dio.dart';

class AnalysisService {
  final ApiClient _apiClient = ApiClient();

  /// 이미지 업로드부터 분석까지 한 번에 처리하는 프로세스
  Future<AnalysisResponse> uploadAndAnalyze(String imagePath) async {
    try {
      // 1. 서버에 Signed URL 요청 (권한 얻기)
      final file = File(imagePath);
      final fileName = imagePath.split('/').last;
      final fileSize = await file.length();

      final urlResponse = await _apiClient.dio.post(
        '/api/images/signed-url',
        data: {
          "fileName": fileName,
          "contentType": "image/jpg", // 필요 시 확장자에 따라 가변 처리
          "fileSize": fileSize,
        },
      );

      final String signedUrl = urlResponse.data['signedUrl'];
      final String publicUrl = urlResponse.data['publicUrl'];

      // 2. 받은 Signed URL로 실제 이미지 파일 업로드 (PUT 방식)
      // 이 때는 ApiClient의 기본 설정(BaseUrl 등)을 타지 않도록 별도의 Dio 객체나 Full URL 사용
      await Dio().put(
        signedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: fileSize,
            "Content-Type": "image/jpeg",
          },
        ),
      );

      log("이미지 업로드 성공: $publicUrl");

      // 3. 업로드된 Public URL을 리스트에 담아 분석 API 호출
      return await _analyzeHazard(publicUrl);

    } on DioException catch (e) {
      log("업로드/분석 중 Dio 에러: ${e.response?.data ?? e.message}");
      throw Exception('처리 실패: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      log("알 수 없는 에러: $e");
      throw Exception('Unknown error: $e');
    }
  }

  /// 기존 분석 API 호출 로직 (내부 메서드로 전환)
  Future<AnalysisResponse> _analyzeHazard(String imageUrl) async {
    final response = await _apiClient.dio.post(
      Apis.analysis,
      data: {
        'imageUrls': [imageUrl], // 서버 요구대로 배열 형태 전달
      },
    );

    if (response.statusCode == 200) {
      return AnalysisResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('분석 응답 실패');
    }
  }
}