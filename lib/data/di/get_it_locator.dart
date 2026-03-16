import 'package:ansim_app/data/service/auth_service.dart';
import 'package:ansim_app/screens/auth/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  ///dio 등록
  getIt.registerLazySingleton<Dio>(() => Dio());
  
  /// AuthProvider 등록
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider());

  /// AuthService 등록
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
