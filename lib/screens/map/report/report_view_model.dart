import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportViewModel extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _capturedImage;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  XFile? get capturedImage => _capturedImage;

  /// 카메라 초기화 및 권한 확인
  Future<void> initializeCamera() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      try {
        await _controller!.initialize();
        _isInitialized = true;
        notifyListeners(); // UI에 초기화 완료 알림
      } catch (e) {
        debugPrint("Camera Init Error: $e");
      }
    } else {
      // 권한 거부 처리 (UI에서 대응할 수 있도록 알림)
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// 사진 촬영
  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _capturedImage = await _controller!.takePicture();
      notifyListeners(); // 촬영된 이미지 업데이트 알림
    } catch (e) {
      debugPrint("Take Picture Error: $e");
    }
  }

  /// 촬영한 사진 초기화 (다시 찍기 등)
  void clearImage() {
    _capturedImage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}