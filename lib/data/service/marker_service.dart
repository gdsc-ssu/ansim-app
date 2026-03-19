import 'dart:developer';

import 'package:ansim_app/constansts/apis.dart';
import 'package:ansim_app/data/di/api_client.dart';
import 'package:ansim_app/data/dto/response/marker_response.dart';
import 'package:dio/dio.dart';

class MarkerService {
  final ApiClient _apiClient = ApiClient();

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
}
