import 'dart:core';

abstract class Apis {
  Apis._();

  /// 토큰 관련 api
  static const String getGoogleAccessToken = "/api/auth/google";
  static const String reFreshToken = "/api/auth/google";
  static const String logOut = "/api/auth/logout";

  /// 신고 관련 api
  static const String analysis = "/api/analysis"; // 이미지 분석


  /// 마커 관련 api
  static const String markers = "/markers";
}