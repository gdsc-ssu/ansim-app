import 'dart:core';

abstract class Apis {
  Apis._();

  /// 토큰 관련 api
  static const String getGoogleAccessToken = "/auth/google";
  static const String reFreshToken = "/auth/refresh";
  static const String logOut = "/auth/logout";
}