import 'dart:async';

import 'package:ansim_app/data/dto/response/marker_response.dart';
import 'package:ansim_app/data/dto/response/report_response.dart';
import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:ansim_app/data/service/marker_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  final SecureStorageRepository _secureStorage = SecureStorageRepository();
  final MarkerService _markerService = MarkerService();

  bool isLoading = true;
  LatLng? currentLocation;
  GoogleMapController? mapController;
  int currentIndex = 0;
  int selectedCategoryIndex = 0;
  final List<String> categories = ["전체", "싱크홀", "도로파손", "붕괴위험", "시설물"];

  Set<Marker> markers = {};
  List<MarkerResponse> markerModels = [];

  ReportResponse? selectedReport;
  bool isLoadingReport = false;

  StreamSubscription<Position>? _locationSubscription;

  // 마커 재조회 기준 거리 (미터)
  static const double _markerRefetchDistance = 200;
  LatLng? _lastFetchedLocation;

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    notifyListeners();
  }

  MapViewModel() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      currentLocation = LatLng(position.latitude, position.longitude);
      _lastFetchedLocation = currentLocation;
      await _fetchNearbyMarkers(position.latitude, position.longitude);
    } catch (e) {
      currentLocation = const LatLng(37.5665, 126.9780);
      debugPrint("Error getting location: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    _startLocationStream();
  }

  void _startLocationStream() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이상 이동 시에만 이벤트 발생
      ),
    ).listen((position) {
      currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();

      // 마지막 마커 조회 위치에서 200m 이상 이동 시 재조회
      if (_lastFetchedLocation != null) {
        final distance = Geolocator.distanceBetween(
          _lastFetchedLocation!.latitude,
          _lastFetchedLocation!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance >= _markerRefetchDistance) {
          _lastFetchedLocation = currentLocation;
          _fetchNearbyMarkers(position.latitude, position.longitude);
        }
      }
    });
  }

  Future<void> _fetchNearbyMarkers(double lat, double lng) async {
    try {
      markerModels = await _markerService.getNearbyMarkers(
        lat: lat,
        lng: lng,
        radius: 100,
      );
      debugPrint('[MapViewModel] 마커 ${markerModels.length}개 조회됨');
      notifyListeners();
    } catch (e) {
      debugPrint('[MapViewModel] 마커 조회 실패: $e');
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void zoomIn() {
    mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void zoomOut() {
    mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void moveToCurrentLocation() {
    if (currentLocation == null) return;
    mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: currentLocation!, zoom: 15.0),
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void changeTab(int index) {
    currentIndex = index;
    notifyListeners();
  }

  void onCategorySelected(int index) {
    selectedCategoryIndex = index;
    notifyListeners();
    // TODO: 카테고리 선택에 따른 추가 액션 구현
  }

  Future<void> fetchReport(String id) async {
    isLoadingReport = true;
    selectedReport = null;
    notifyListeners();
    try {
      selectedReport = await _markerService.getReport(id);
    } catch (e) {
      debugPrint('[MapViewModel] 신고 조회 실패: $e');
    } finally {
      isLoadingReport = false;
      notifyListeners();
    }
  }

  void clearSelectedReport() {
    selectedReport = null;
    notifyListeners();
  }

  Future<bool> checkIsLoggedIn() async {
    return await _secureStorage.readIsLoggedIn();
  }
}
