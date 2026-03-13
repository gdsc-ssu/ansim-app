import 'package:ansim_app/data/service/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  ///dio 등록
  getIt.registerLazySingleton<Dio>(() => Dio());
  
  /// AuthService 등록
  getIt.registerLazySingleton<AuthService>(() => AuthService());
}
