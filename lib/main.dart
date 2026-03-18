import 'package:ansim_app/data/di/get_it_locator.dart';
import 'package:ansim_app/screens/auth/auth_provider.dart';
import 'package:ansim_app/route/routes.dart';
import 'package:ansim_app/screens/map/map_view_model.dart';
import 'package:ansim_app/screens/map/report/report_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. 환경변수 로드
    await dotenv.load(fileName: ".env");

    // 3. DI 설정
    setupServiceLocator();

    debugPrint("앱 초기화 완료");
  } catch (e) {
    debugPrint("초기화 과정 중 에러 발생: $e");
  }

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: GetIt.I<AuthProvider>()),
          ChangeNotifierProvider(create: (_) => ReportViewModel()),
          ChangeNotifierProvider(create: (_) => MapViewModel()),
        ],
        child: const MyApp(),
  ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ansim',
      routerConfig: AppRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
    );
  }
}