import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportViewModel extends ChangeNotifier {
  // 1. 카메라 관련 상태
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _capturedImage;

  // 2. 신고 데이터 관련 상태 (초기값은 AI 분석 결과로 채워질 예정)
  String _selectedType = "싱크홀";
  String _selectedLevel = "심각";
  String _address = "서울 강동구 천호대로 42길";
  final TextEditingController descriptionController = TextEditingController();

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  XFile? get capturedImage => _capturedImage;
  String get selectedType => _selectedType;
  String get selectedLevel => _selectedLevel;
  String get address => _address;

  // --- 카메라 로직 ---

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
        notifyListeners();
      } catch (e) {
        debugPrint("Camera Init Error: $e");
      }
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      _capturedImage = await _controller!.takePicture();
      notifyListeners();
    } catch (e) {
      debugPrint("Take Picture Error: $e");
    }
  }

  // --- 신고 데이터 로직 ---

  /// 위험 유형 변경
  void setType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  /// 위험도 레벨 변경
  void setLevel(String level) {
    _selectedLevel = level;
    notifyListeners();
  }

  /// 주소 업데이트 (지도 선택 등에서 활용)
  void setAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
  }

  /// AI 분석 데이터 세팅 (AiAnalysisScreen에서 호출)
  void setAnalysisResult({required String type, required String level}) {
    _selectedType = type;
    _selectedLevel = level;
    notifyListeners();
  }

  /// 최종 제보하기 서버 전송
  Future<bool> submitReport() async {
    if (_capturedImage == null) return false;

    try {
      // API 전송 로직 예시
      // final success = await _repository.uploadReport(
      //   image: _capturedImage!,
      //   type: _selectedType,
      //   level: _selectedLevel,
      //   address: _address,
      //   description: descriptionController.text,
      // );

      debugPrint("제보 완료: $_selectedType / $_selectedLevel / $_address");
      return true;
    } catch (e) {
      debugPrint("제보 실패: $e");
      return false;
    }
  }

  void setImage(XFile image) {
    _capturedImage = image;

    // 이미지가 세팅되면 UI를 다시 그리도록 알림 (미리보기 등에 반영)
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}