import 'dart:developer';

import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/marker_response.dart';
import 'package:ansim_app/data/dto/response/report_response.dart';
import 'package:dio/dio.dart';

class MarkerService {
  final ApiClient _apiClient = ApiClient();

  /// 마커 생성 (신고 + 마커 동시 생성)
  Future<void> createMarker({
    required double latitude,
    required double longitude,
    required String hazardType,
    required String hazardLevel,
    required String description,
    List<Map<String, dynamic>>? images,
  }) async {
    try {
      await _apiClient.dio.post(
        Apis.markers,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'hazardType': hazardType,
          'hazardLevel': hazardLevel,
          'description': description,
          if (images != null) 'images': images,
        },
      );
      log('[MarkerService] 마커 생성 성공');
    } catch (e) {
      log('[MarkerService] 마커 생성 실패: $e');
      rethrow;
    }
  }

  Future<List<MarkerResponse>> getNearbyMarkers({
    required double lat,
    required double lng,
    required double radius,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        Apis.markers,
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
        options: Options(extra: {'skipAuthToken': true}),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MarkerResponse.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      log('[MarkerService] 마커 조회 실패: $e');
      rethrow;
    }
  }

  Future<ReportResponse> getReport(String id) async {
    try {
      final response = await _apiClient.dio.get('${Apis.markers}/$id');
      return ReportResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      log('[ReportService] 신고 단건 조회 실패: $e');
      rethrow;
    }
  }
}
