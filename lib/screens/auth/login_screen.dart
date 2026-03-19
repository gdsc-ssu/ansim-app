import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/auth/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginViewModel _viewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _navigateAfterLogin(BuildContext context) async {
    final status = await Permission.locationWhenInUse.status;
    if (!context.mounted) return;
    if (status.isGranted) {
      context.go(Paths.map);
    } else {
      context.go(Paths.permission);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              SvgPicture.asset('assets/logo.svg', width: 80, height: 80),
              const SizedBox(height: 24),
              const Text('안심', style: AnsimTextStyle.headingH1),
              const SizedBox(height: 8),
              const Text('우리 동네 안전을 함께 지켜요', style: AnsimTextStyle.bodyB2),
              const Spacer(flex: 2),

              _viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                onTap: () async {
                  try {
                    await _viewModel.signInWithGoogle(context);
                    if (!context.mounted) return;

                    if (_viewModel.errorMessage == null) {
                      await _navigateAfterLogin(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_viewModel.errorMessage!)),
                      );
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    if (_viewModel.errorMessage != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_viewModel.errorMessage!)),
                      );
                    }
                  }
                },
                child: SvgPicture.asset(
                  'assets/images/img_google_login.svg',
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),

              TextButton(
                onPressed: () => _navigateAfterLogin(context),
                child: const Text('둘러보기', style: AnsimTextStyle.tabLable),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}