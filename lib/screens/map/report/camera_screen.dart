import 'dart:io';
import 'package:ansim_app/constansts/paths.dart'; // Paths.aiAnalysis 사용을 위해 필요
import 'package:ansim_app/screens/map/report/report_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatelessWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel이 이미 상위에서 제공되고 있지 않다면 여기서 생성,
    // 이미 주입되어 있다면 context.read/watch를 사용하세요.
    return ChangeNotifierProvider(
      create: (_) => ReportViewModel()..initializeCamera(),
      child: Consumer<ReportViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.isInitialized || viewModel.controller == null) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              fit: StackFit.expand,
              children: [
                // 1. 카메라 프리뷰
                CameraPreview(viewModel.controller!),

                // 2. 가이드 레이아웃 (디자인 가이드 반영)
                _buildOverlay(context),

                // 3. 상단 제어 버튼
                _buildTopControls(context),

                // 4. 하단 제어 버튼 (갤러리, 촬영, 전환)
                _buildBottomControls(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  // 중앙 가이드 박스 및 안내 문구
  Widget _buildOverlay(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white.withOpacity(0.8),
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "위험 요소를 촬영해 주세요",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 상단 버튼: 닫기 및 가이드 아이콘
  Widget _buildTopControls(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _circleIconButton(Icons.close, () => context.pop()),
            _circleIconButton(Icons.filter_center_focus, () {}),
          ],
        ),
      ),
    );
  }

  // 하단 버튼: 촬영 로직 포함
  Widget _buildBottomControls(BuildContext context, ReportViewModel viewModel) {
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 갤러리 버튼 (임시 아이콘)
            _squareIconButton(Icons.photo_library_outlined, () {
              // TODO: 갤러리 연동 로직
            }),

            // 촬영 버튼
            GestureDetector(
              onTap: () async {
                await viewModel.takePicture();
                if (viewModel.capturedImage != null && context.mounted) {
                  // 촬영 성공 시 aiAnalysis 화면으로 이동 (ViewModel 함께 전달)
                  context.push(
                    Paths.aiAnalysis,
                    extra: {
                      'image': viewModel.capturedImage,
                      'viewModel': viewModel,
                    },
                  );
                }
              },
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // 카메라 전환 버튼
            _squareIconButton(Icons.cached, () {
              // TODO: 카메라 전환(전면/후면) 로직 구현
            }),
          ],
        ),
      ),
    );
  }

  Widget _circleIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _squareIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}