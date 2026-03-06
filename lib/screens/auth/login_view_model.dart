import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;

  // 로그인 상태 확인용 (외부에서는 읽기만 가능)
  bool get isLoading => _isLoading;

  // 구글 로그인 실행 함수
  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);

    try {
      // TODO: 실제 Firebase Auth 또는 Google Sign In 로직이 들어갈 자리입니다.

      // 테스트를 위한 가상 딜레이 (2초)
      await Future.delayed(const Duration(seconds: 2));

      print("로그인 성공!");

      // 로그인 성공 후 메인 화면으로 이동 (예시)
      // Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      print("로그인 실패: $e");
      // 필요 시 에러 팝업 로직 추가
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // 상태 변경을 UI에 알림
  }
}