import 'package:ansim_app/common/widgets/ansim_button.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart'; // 텍스트 스타일 임포트
import 'package:ansim_app/constansts/constants.dart';
import 'package:ansim_app/screens/auth/permission/permission_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PermissionViewModel _viewModel = PermissionViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // 1. 상단 원형 배경 로고
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(

                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/logo.svg', // 위치 핀 로고
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 2. 메인 타이틀
              const Text(
                '위치 정보가 필요해요',
                style: AnsimTextStyle.headingH2,
              ),
              const SizedBox(height: 12),

              // 3. 서브 타이틀 (설명 텍스트)
              Text(
                '내 주변의 위험 요소를 확인하고\n근접 알림을 받으려면\n위치 접근을 허용해 주세요',
                textAlign: TextAlign.center,
                style: AnsimTextStyle.bodyB2.copyWith(color: AnsimColor.textSecondary),
              ),
              const SizedBox(height: 40),

              // 4. 권한 리스트 항목들
              _buildPermissionItem(
                icon: Icons.location_on_outlined,
                title: '위치 (필수)',
                description: '주변 위험 표시 및 근접 알림',

              ),
              _buildPermissionItem(
                icon: Icons.notifications_none_outlined,
                title: '알림 (선택)',
                description: '긴급 위험 및 내 신고 결과 알림',
              ),
              _buildPermissionItem(
                icon: Icons.camera_alt_outlined,
                title: '카메라 (선택)',
                description: '위험 현장 촬영 및 신고',
              ),

              const Spacer(),

              // 5. 허용하기 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: AnsimButton(
                  text: '허용하기',
                  onPressed: () => _viewModel.requestAllPermissions(context),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // 권한 항목을 구성하는 위젯 함수
  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          // 아이콘 배경 박스
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 16),
          // 텍스트 설명 부분
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}