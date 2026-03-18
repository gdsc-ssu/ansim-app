import 'package:ansim_app/common/enums/hazard_level.dart'; // Enum import
import 'package:ansim_app/common/enums/hazard_type.dart';  // Enum import
import 'package:ansim_app/data/dto/response/analysis_response.dart';
import 'package:ansim_app/data/service/analysis_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportViewModel extends ChangeNotifier {
  // --- 주입 (DI) ---
  final AnalysisService _analysisService = AnalysisService();

  // 1. 카메라 및 UI 상태
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _capturedImage;
  bool _isAnalyzing = false; // 분석 중 로딩 상태 추가

  // 2. 신고 데이터 관련 상태 (내부적으로는 Enum으로 관리하는 것이 좋습니다)
  HazardType _hazardType = HazardType.SINKHOLE; // 기본값
  HazardLevel _hazardLevel = HazardLevel.HIGH;  // 기본값
  String _address = "서울 강동구 천호대로 42길";
  final TextEditingController descriptionController = TextEditingController();

  // Getters (UI에서 사용할 땐 한글 String으로 변환해서 제공)
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  XFile? get capturedImage => _capturedImage;
  bool get isAnalyzing => _isAnalyzing; // 로딩 상태 Getter

  // UI 표현을 위한 한글 Getters (매핑 필요)
  String get selectedTypeStr => _mapHazardTypeToString(_hazardType);
  String get selectedLevelStr => _mapHazardLevelToString(_hazardLevel);
  String get address => _address;

  // --- 카메라 로직 --- (기존과 동일)

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
      final image = await _controller!.takePicture();
      // 💡 사진을 찍으면 바로 setImage를 호출하여 분석을 시작하게 합니다.
      setImage(image);
    } catch (e) {
      debugPrint("Take Picture Error: $e");
    }
  }

  // --- 💡 핵심: 이미지 설정 및 AI 분석 연결 ---

  void setImage(XFile image) {
    _capturedImage = image;
    notifyListeners(); // 미리보기 즉시 반영

    // 이미지가 설정되면 자동으로 AI 분석 요청
    _analyzeImage(image.path);
  }

  /// 내부 분석 메서드
  Future<void> _analyzeImage(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners(); // 로딩 시작

    try {
      // 💡 서비스 호출
      final AnalysisResponse result = await _analysisService.uploadAndAnalyze(imagePath);

      // 💡 결과를 뷰 모델 상태에 반영
      _hazardType = result.hazardType;
      _hazardLevel = result.hazardLevel;

      debugPrint("AI 분석 완료: ${_hazardType.name} / ${_hazardLevel.name}");
    } catch (e) {
      debugPrint("AI 분석 실패 (기본값 유지): $e");
      // 실패 시 에러 팝업을 띄우거나 기본값(싱크홀/심각)을 유지합니다.
    } finally {
      _isAnalyzing = false;
      notifyListeners(); // 로딩 종료 및 데이터 반영
    }
  }

  // --- 신고 데이터 로직 ---

  /// UI에서 위험 유형 변경 (String -> Enum으로 변환 저장)
  void setType(String typeStr) {
    // 💡 간단한 역매핑 필요
    if (typeStr == "싱크홀") _hazardType = HazardType.SINKHOLE;
    if (typeStr == "침수") _hazardType = HazardType.FLOOD;
    // ... 나머지 케이스
    notifyListeners();
  }

  /// UI에서 위험도 레벨 변경 (String -> Enum으로 변환 저장)
  void setLevel(String levelStr) {
    if (levelStr == "심각") _hazardLevel = HazardLevel.HIGH;
    if (levelStr == "보통") _hazardLevel = HazardLevel.MEDIUM;
    // ... 나머지 케이스
    notifyListeners();
  }

  // ... (setAddress, dispose 등 기존과 동일)

  /// 최종 제보하기 서버 전송
  Future<bool> submitReport() async {
    if (_capturedImage == null || _isAnalyzing) return false;

    try {
      // API 전송 로직 시 Enum 값을 .name으로 보냅니다.
      debugPrint("제보 완료: ${_hazardType.name} / ${_hazardLevel.name} / $_address");
      return true;
    } catch (e) {
      debugPrint("제보 실패: $e");
      return false;
    }
  }

  // --- 매핑 유틸리티 (ViewModel 내부에 정의하거나 별도 헬퍼 클래스로 분리) ---
  String _mapHazardTypeToString(HazardType type) {
    switch (type) {
      case HazardType.SINKHOLE: return "싱크홀";
      case HazardType.FLOOD: return "침수";
      case HazardType.FIRE: return "화재";
      case HazardType.UNKNOWN: return "기타";
      default: return "알 수 없음";
    }
  }

  String _mapHazardLevelToString(HazardLevel level) {
    switch (level) {
      case HazardLevel.HIGH: return "심각";
      case HazardLevel.MEDIUM: return "보통";
      case HazardLevel.LOW: return "주의";
      default: return "알 수 없음";
    }
  }
}