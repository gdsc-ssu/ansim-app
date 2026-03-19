import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/auth/login_screen.dart';
import 'package:ansim_app/screens/auth/permission/permission_screen.dart';
import 'package:ansim_app/common/widgets/navigation_screen.dart';
import 'package:ansim_app/screens/map/report/ai_analysis_screen.dart';
import 'package:ansim_app/screens/map/report/camera_screen.dart';
import 'package:ansim_app/screens/map/report/report_screen.dart';
import 'package:ansim_app/screens/map/report/report_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final AppRouter = GoRouter(initialLocation: Paths.login, routes: [
  GoRoute(
      path: Paths.login,
      pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginScreen(),
          )),
  GoRoute(
      path: Paths.permission,
      pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const PermissionScreen(),
          )),
  GoRoute(
      path: Paths.map,
      pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const NavigationScreen(),
          )),
  GoRoute(
      path: Paths.camera,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const CameraScreen(),
      )),
  GoRoute(
    path: Paths.aiAnalysis,
    pageBuilder: (context, state) {
      final image = state.extra as XFile;

      return MaterialPage(
        key: state.pageKey,
        child: AiAnalysisScreen(image: image),
      );
    },
  ),
  GoRoute(
    path: Paths.report,
    pageBuilder: (context, state) {
      final image = state.extra as XFile;

      return MaterialPage(
        key: state.pageKey,
        child: ChangeNotifierProvider(
          create: (_) => ReportViewModel(),
          child: ReportScreen(image: image),
        ),
      );
    },
  ),
]);
