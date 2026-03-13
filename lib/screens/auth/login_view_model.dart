import 'dart:developer';

import 'package:ansim_app/common/enums/login_platform.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:ansim_app/data/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class LoginViewModel extends ChangeNotifier {
  final AuthService authService = GetIt.instance<AuthService>();

  bool _isLoading = false;
  String? _errorMessage;

  // 로그인 상태 확인용 (외부에서는 읽기만 가능)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LoginPlatform _loginPlatform = LoginPlatform.none;


  /// 현재 플랫폼이 iOS인지 확인 (웹 제외)
  bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// 현재 플랫폼이 Android인지 확인
  bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  // 구글 로그인 실행 함수
  Future<void> signInWithGoogle(BuildContext context) async {
    _errorMessage = null;

    String? clientId;

    if (isIOS) {
      clientId = dotenv.get("CLIENT_ID", fallback: null);
      log("사용 중인 CLIENT_ID: $clientId"); // 디버깅용
    } else {
      clientId = null;
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: clientId,
      scopes: ['email', 'profile'],
    );

    try {
      log("Google 로그인 시작...");
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      log("Google 로그인 결과: ${googleUser != null ? '성공' : '실패/취소'}");

      if (googleUser == null) {
        log('사용자가 로그인을 취소했습니다');
        _errorMessage = '로그인이 취소되었습니다.';
        notifyListeners();
        return;
      }

      log('name = ${googleUser.displayName}');
      log('email = ${googleUser.email}');
      log('id = ${googleUser.id}');

      final name = googleUser.displayName;

      log("인증 정보 가져오는 중...");
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      log("accessToken: ${googleAuth.accessToken}");
      log("idToken: ${googleAuth.idToken}");

      final authCode = googleAuth.accessToken;

      if (authCode == null || authCode.isEmpty) {
        log('❌ accessToken이 null입니다!');

        // iOS에서는 idToken을 사용해야 할 수도 있음
        final idToken = googleAuth.idToken;
        if (idToken != null && idToken.isNotEmpty) {
          log('✅ idToken은 있습니다. idToken 사용 시도');
          // 서버가 idToken을 받는다면 이것을 사용
          final response =
          await authService.getGoogleAccessToken(idToken, name!);
          await _saveUserInfo(name, googleUser.email);
          _loginPlatform = LoginPlatform.google;
          notifyListeners();
          return;
        }

        _errorMessage = '인증 토큰을 받아오지 못했습니다. 다시 시도해주세요.';
        notifyListeners();
        return;
      }

      if (name == null || name.isEmpty) {
        log('사용자 이름을 받아오지 못했습니다');
        _errorMessage = '사용자 정보를 받아오지 못했습니다. 다시 시도해주세요.';
        notifyListeners();
        return;
      }

      log("서버에 토큰 전송 중...");
      final response = await authService.getGoogleAccessToken(authCode, name);

      await _saveUserInfo(name, googleUser.email);
      _loginPlatform = LoginPlatform.google;


      notifyListeners();
    } catch (e, stackTrace) {
      log("❌ Exception occurred: $e");
      log("Stack trace: $stackTrace");
      _errorMessage = 'Google 로그인에 실패했습니다. 다시 시도해주세요.';
      if (e is DioException) {
        log("DioError details: ${e.response?.data}");
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _saveUserInfo(String? name, String? email) async {
    final SecureStorageRepository secureStorage = SecureStorageRepository();
    secureStorage.saveUserName(name ?? '');
    secureStorage.saveUserEmail(email ?? '');
  }


  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // 상태 변경을 UI에 알림
  }
}