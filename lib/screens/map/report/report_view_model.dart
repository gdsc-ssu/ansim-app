import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:ansim_app/data/service/analysis_service.dart';
import 'package:ansim_app/data/service/marker_service.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ReportViewModel extends ChangeNotifier {
  // --- 의존성 주입 (Service) ---
  final AnalysisService _analysisService = AnalysisService();
  final MarkerService _markerService = MarkerService();
  final SecureStorageRepository _secureStorage = SecureStorageRepository();

  // --- 1. 카메라 및 상태 관리 ---
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _capturedImage;
  bool _isAnalyzing = false; // AI 분석 중 로딩 상태

  // --- 2. 신고 데이터 (내부 상태는 Enum으로 관리) ---
  HazardType _hazardType = HazardType.SINKHOLE;
  HazardLevel _hazardLevel = HazardLevel.HIGH;
  String _address = "";
  final TextEditingController descriptionController = TextEditingController();

  // --- 업로드된 이미지 정보 (신고 제출 시 사용) ---
  String? _uploadedImageUrl;
  String? _uploadedImageMimeType;
  int? _uploadedImageFileSize;

  // --- 3. 위치 데이터 ---
  double? latitude;
  double? longitude;

  // --- Getters ---
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  XFile? get capturedImage => _capturedImage;
  bool get isAnalyzing => _isAnalyzing;

  // UI용 Getter: Enum 내부의 koLabel을 활용해 한글 문자열 반환
  String get selectedTypeStr => _hazardType.koLabel;
  String get selectedLevelStr => _hazardLevel.koLabel;
  String get address => _address;

  // --- 카메라 로직 ---
  Future<void> initializeCamera() async {
    _fetchCurrentLocation();
    _secureStorage.readUserAddress().then((saved) {
      if (saved != null && saved.isNotEmpty && _address.isEmpty) {
        _address = saved;
        notifyListeners();
      }
    });

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
        debugPrint("카메라 초기화 에러: $e");
      }
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint('현재 위치: lat=$latitude, lng=$longitude');
      notifyListeners();
    } catch (e) {
      debugPrint('위치 조회 실패: $e');
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final image = await _controller!.takePicture();
      setImage(image); // 사진 촬영 후 즉시 세팅 및 분석 시작
    } catch (e) {
      debugPrint("사진 촬영 에러: $e");
    }
  }

  // --- 이미지 세팅 및 AI 분석 로직 ---
  void setImage(XFile image) {
    _capturedImage = image;
    notifyListeners(); // 이미지 미리보기 즉시 반영

    // 이미지가 들어오면 자동으로 서버 업로드 및 분석 실행
    _runAiAnalysis(image.path);
  }

  Future<void> _runAiAnalysis(String imagePath) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      // Service의 통합 메서드 호출 (URL 획득 -> 업로드 -> 분석)
      final result = await _analysisService.uploadAndAnalyze(imagePath);

      // 분석 결과를 Enum 상태에 반영
      _hazardType = result.analysis.hazardType;
      _hazardLevel = result.analysis.hazardLevel;

      // 업로드된 이미지 정보 저장 (신고 제출 시 사용)
      _uploadedImageUrl = result.imageUrl;
      _uploadedImageMimeType = result.mimeType;
      _uploadedImageFileSize = result.fileSize;

      debugPrint("AI 분석 완료: ${_hazardType.name} (${_hazardType.koLabel})");
    } catch (e) {
      debugPrint("AI 분석 실패: $e");
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  // --- UI 상호작용 로직 ---

  /// UI(Chip/Button)에서 한글 이름을 넘겨주면 Enum으로 역매핑하여 저장
  void setType(String typeStr) {
    _hazardType = HazardType.fromKoLabel(typeStr);
    notifyListeners();
  }

  void setLevel(String levelStr) {
    _hazardLevel = HazardLevel.fromKoLabel(levelStr);
    notifyListeners();
  }

  void setAddress(String newAddress) {
    _address = newAddress;
    notifyListeners();
  }

  /// 최종 신고 제출
  Future<bool> submitReport() async {
    if (_capturedImage == null || _isAnalyzing) return false;
    if (latitude == null || longitude == null) return false;

    try {
      final description = descriptionController.text.trim().isEmpty
          ? '${_hazardType.koLabel} ${_hazardLevel.koLabel}'
          : descriptionController.text.trim();

      List<Map<String, dynamic>>? images;
      if (_uploadedImageUrl != null) {
        images = [
          {
            'url': _uploadedImageUrl!,
            'mimeType': _uploadedImageMimeType ?? 'image/jpeg',
            'size': _uploadedImageFileSize ?? 0,
          },
        ];
      }

      await _markerService.createMarker(
        latitude: latitude!,
        longitude: longitude!,
        hazardType: _hazardType.name,
        hazardLevel: _hazardLevel.name,
        description: description,
        images: images,
      );

      debugPrint("신고 제출 성공: ${_hazardType.name} / ${_hazardLevel.name}");
      return true;
    } catch (e) {
      debugPrint("신고 제출 에러: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}