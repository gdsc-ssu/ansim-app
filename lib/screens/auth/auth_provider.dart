import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';

class AuthProvider extends ChangeNotifier {
  final SecureStorageRepository _storage = SecureStorageRepository();
  bool _isLoggedIn = false;
  bool _isLoading = true;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();
    final token = await _storage.readAccessToken();
    _isLoggedIn = token != null && token.isNotEmpty;
    _isLoading = false;
    log('[AuthProvider] checkLoginStatus: $_isLoggedIn');
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.deleteAllData();
    _isLoggedIn = false;
    log('[AuthProvider] logout');
    notifyListeners();
  }
}
