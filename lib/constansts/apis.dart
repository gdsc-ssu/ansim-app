import 'dart:core';

abstract class Apis {
  Apis._();

  /// 토큰 관련 api
  static const String getGoogleAccessToken = "/api/auth/google";
  static const String reFreshToken = "/api/auth/google";
  static const String logOut = "/api/auth/logout";

  /// 신고 관련 api
  static const String analysis = "/api/analysis"; // 이미지 분석
  static const String reports = "/api/reports"; // 신고 단건 조회


  /// 마커 관련 api
  static const String markers = "/api/markers";

  /// 유저 관련 api
  static const String userMe = "/api/users/me";
  static const String userSettings = "/api/users/me/settings";

  /// 이미지 관련 api
  static const String imageSignedUrl = "/api/images/signed-url";
}