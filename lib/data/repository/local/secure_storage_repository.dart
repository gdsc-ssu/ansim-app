import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ///토큰
  Future<String?> readAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: "access_token", value: accessToken);
  }

  Future<String?> readRefreshToken() async {
    return await _storage.read(key: "refresh_token");
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: "refresh_token", value: refreshToken);
  }


  ///유저 정보
  Future<String?> readUserName() async {
    return await _storage.read(key: "user_name");
  }

  Future<void> saveUserName(String name) async {
    await _storage.write(key: "user_name", value: name);
  }

  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: "user_email", value: email);
  }

  Future<String?> readUserEmail() async {
    return await _storage.read(key: "user_email");
  }

  Future<void> saveUserId(int userId) async {
    await _storage.write(key: 'userId', value: userId.toString());
  }

  Future<int?> getUserId() async {
    final value = await _storage.read(key: 'userId');
    return value != null ? int.tryParse(value) : null;
  }

  ///로그인 상태
  Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    await _storage.write(key: "is_logged_in", value: isLoggedIn.toString());
  }

  Future<bool> readIsLoggedIn() async {
    final value = await _storage.read(key: "is_logged_in");
    return value == "true";
  }

  ///주소
  Future<void> saveUserAddress(String address) async {
    await _storage.write(key: "user_address", value: address);
  }

  Future<String?> readUserAddress() async {
    return await _storage.read(key: "user_address");
  }

  ///모든 데이터 삭제
  Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }
}
