import 'dart:developer';
import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/analysis_response.dart';
import 'package:dio/dio.dart';

class AnalysisService {
  final ApiClient _apiClient = ApiClient();

  /// 이미지 위험도 분석 요청
  /// [imageUrl] 분석할 이미지의 URL
  Future<AnalysisResponse> analyzeHazard(String imageUrl) async {
    try {
      final response = await _apiClient.dio.post(
        Apis.analysis,
        data: {
          'imageUrls': [imageUrl], // 리스트 형태인지 확인 필요
        },
        options: Options(
          extra: {'skipAuthToken': false}, // 인증 토큰 포함 여부
        ),
      );

      if (response.statusCode == 200) {
        // 서버 응답 데이터를 DTO로 변환
        final analysisResult = AnalysisResponse.fromJson(response.data as Map<String, dynamic>);

        log("분석 결과 - 타입: ${analysisResult.hazardType}, 등급: ${analysisResult.hazardLevel}");
        return analysisResult;
      } else {
        throw Exception('위험 분석 실패: ${response.data.toString()}');
      }
    } on DioException catch (e) {
      log("Dio 에러 발생: ${e.response?.data}");
      throw Exception('네트워크 에러: ${e.response?.data?['message'] ?? e.message}');
    } catch (e) {
      log("알 수 없는 에러 발생: $e");
      throw Exception('Unknown error: $e');
    }
  }
}