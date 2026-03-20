import 'dart:io';
import 'dart:developer';
import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/analysis_response.dart';
import 'package:dio/dio.dart';

/// 업로드 + AI 분석 결과를 함께 반환하는 클래스
class UploadAndAnalysisResult {
  final AnalysisResponse? analysis;
  final String imageUrl;
  final String mimeType;
  final int fileSize;

  UploadAndAnalysisResult({
    this.analysis,
    required this.imageUrl,
    required this.mimeType,
    required this.fileSize,
  });
}

class AnalysisService {
  final ApiClient _apiClient = ApiClient();

  /// 이미지 업로드부터 분석까지 한 번에 처리하는 프로세스
  /// AI 분석 실패 시에도 이미지 업로드 결과는 반환 (analysis가 null)
  Future<UploadAndAnalysisResult> uploadAndAnalyze(String imagePath) async {
    try {
      // 1. 서버에 Signed URL 요청 (권한 얻기)
      final file = File(imagePath);
      final fileName = imagePath.split('/').last;
      final fileSize = await file.length();
      const mimeType = 'image/jpeg';

      final urlResponse = await _apiClient.dio.post(
        Apis.imageSignedUrl,
        data: {
          "fileName": fileName,
          "contentType": mimeType,
          "fileSize": fileSize,
        },
      );

      final String signedUrl = urlResponse.data['signedUrl'];
      final String publicUrl = urlResponse.data['publicUrl'];

      // 2. Signed URL로 GCS에 파일 직접 업로드
      await Dio().put(
        signedUrl,
        data: file.openRead(),
        options: Options(
          headers: {
            Headers.contentLengthHeader: fileSize,
            'Content-Type': mimeType,
            'x-goog-content-length-range': '0,$fileSize',
          },
        ),
      );

      log("GCS 업로드 완료: $publicUrl");

      // 3. AI 분석 API 호출 (실패해도 업로드 결과는 반환)
      AnalysisResponse? analysis;
      try {
        analysis = await _analyzeHazard(publicUrl);
      } catch (e) {
        log("AI 분석 실패 (이미지 업로드는 성공): $e");
      }

      return UploadAndAnalysisResult(
        analysis: analysis,
        imageUrl: publicUrl,
        mimeType: mimeType,
        fileSize: fileSize,
      );
    } on DioException catch (e) {
      log("업로드 중 Dio 에러: ${e.response?.data ?? e.message}");
      throw Exception('업로드 실패: ${e.response?.data?['message'] ?? e.message}');
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return AnalysisResponse.fromJson(response.data as Map<String, dynamic>);
    } else {
      throw Exception('분석 응답 실패');
    }
  }
}