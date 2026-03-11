import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/auth/login_screen.dart';
import 'package:ansim_app/screens/auth/permission/permission_screen.dart';
import 'package:ansim_app/common/widgets/navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final AppRouter = GoRouter(initialLocation: Paths.permission, routes: [
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
]);
