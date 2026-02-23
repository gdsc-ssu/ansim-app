import 'package:ansim_app/constansts/paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final AppRouter = GoRouter(
    initialLocation: Paths.splash,
    routes: [
    GoRoute(
    path: Paths.splash,
    pageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: SplashScreen(),
    )),

      GoRoute(
          path: Paths.login,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginScreen(),
          )),

  ]
);