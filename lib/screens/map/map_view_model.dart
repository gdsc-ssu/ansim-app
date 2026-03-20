import 'dart:async';

import 'package:ansim_app/common/enums/hazard_type.dart';
import 'package:ansim_app/data/di/get_it_locator.dart';
import 'package:ansim_app/data/service/notification_service.dart';
import 'package:ansim_app/screens/alarm/alarm_view_model.dart';
import 'package:geocoding/geocoding.dart';
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
  HazardType? selectedCategory; // null = 전체

  Set<Marker> markers = {};
  List<MarkerResponse> markerModels = [];

  ReportResponse? selectedReport;
  bool isLoadingReport = false;

  StreamSubscription<Position>? _locationSubscription;

  // 마커 재조회 기준 거리 (미터)
  static const double _markerRefetchDistance = 200;
  LatLng? _lastFetchedLocation;

  // 근접 알림 거리
  static const double _emergencyDistance = 3.0;
  static const double _nearbyDistance = 5.0;

  // 중복 알림 방지 (마커 ID 추적)
  final Set<String> _notifiedEmergency = {};
  final Set<String> _notifiedNearby = {};

  // 줌 레벨 기반 마커 반경
  double _currentZoom = 15.0;
  double _lastFetchedZoom = 15.0;

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    notifyListeners();
  }

  MapViewModel() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      // iOS에서 geolocator가 CLLocationManager 권한을 직접 확인/요청
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        debugPrint('[MapViewModel] 위치 권한 영구 거부');
        currentLocation = const LatLng(37.5665, 126.9780);
        isLoading = false;
        notifyListeners();
        _startLocationStream();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      currentLocation = LatLng(position.latitude, position.longitude);
      _lastFetchedLocation = currentLocation;
      await Future.wait([
        _fetchNearbyMarkers(position.latitude, position.longitude),
        _saveAddressFromPosition(position.latitude, position.longitude),
      ]);
    } catch (e) {
      currentLocation = const LatLng(37.5665, 126.9780);
      debugPrint("Error getting location: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
    _startLocationStream();
  }

  Future<void> _saveAddressFromPosition(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return;
      final p = placemarks.first;
      final address = [p.administrativeArea, p.subLocality, p.thoroughfare]
          .where((s) => s != null && s.isNotEmpty)
          .join(' ');
      if (address.isNotEmpty) {
        await _secureStorage.saveUserAddress(address);
        debugPrint('[MapViewModel] 주소 저장: $address');
      }
    } catch (e) {
      debugPrint('[MapViewModel] 주소 획득 실패: $e');
    }
  }

  void _startLocationStream() {
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1, // 1m 단위로 감지 (근접 알림 정확도)
      ),
    ).listen((position) {
      currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();

      _checkProximityAlerts(position);

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

  void _checkProximityAlerts(Position position) {
    for (final marker in markerModels) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        marker.latitude,
        marker.longitude,
      );

      if (distance <= _emergencyDistance) {
        if (!_notifiedEmergency.contains(marker.id)) {
          _notifiedEmergency.add(marker.id);
          _notifiedNearby.add(marker.id);
          final label = marker.hazardType.koLabel;
          NotificationService.instance.show(
            id: marker.id.hashCode,
            title: '긴급 위험 알림',
            body: '$label 위험 지점 3m 이내에 있습니다. 즉시 대피하세요.',
          );
          getIt<AlarmViewModel>().addEmergencyAlarm(
            markerId: marker.id,
            hazardTypeLabel: label,
          );
        }
      } else if (distance <= _nearbyDistance) {
        if (!_notifiedNearby.contains(marker.id)) {
          _notifiedNearby.add(marker.id);
          final label = marker.hazardType.koLabel;
          NotificationService.instance.show(
            id: marker.id.hashCode + 1,
            title: '주변 위험 감지',
            body: '$label 위험 지점 5m 이내에 있습니다. 주의하세요.',
          );
          getIt<AlarmViewModel>().addNearbyAlarm(
            markerId: marker.id,
            hazardTypeLabel: label,
          );
        }
      } else {
        // 범위 벗어나면 알림 초기화 (재진입 시 다시 알림 가능)
        _notifiedNearby.remove(marker.id);
        _notifiedEmergency.remove(marker.id);
      }
    }
  }

  /// 줌 레벨에 따른 마커 조회 반경 계산 (미터, 최대 300)
  int _radiusFromZoom(double zoom) {
    if (zoom >= 17) return 100;
    if (zoom >= 15) return 200;
    return 300;
  }

  /// 카메라 이동 완료 시 호출 — 줌 변화에 따라 마커 재조회
  void onCameraIdle(double zoom) {
    _currentZoom = zoom;
    final zoomDiff = (_currentZoom - _lastFetchedZoom).abs();
    if (zoomDiff >= 1.0 && currentLocation != null) {
      _lastFetchedZoom = _currentZoom;
      _lastFetchedLocation = currentLocation;
      _fetchNearbyMarkers(currentLocation!.latitude, currentLocation!.longitude);
    }
  }

  Future<void> _fetchNearbyMarkers(double lat, double lng) async {
    try {
      final radius = _radiusFromZoom(_currentZoom);
      markerModels = await _markerService.getNearbyMarkers(
        lat: lat,
        lng: lng,
        radius: radius.toDouble(),
      );
      debugPrint('[MapViewModel] 마커 ${markerModels.length}개 조회됨 (radius=$radius, zoom=$_currentZoom)');
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

  void onCategorySelected(HazardType? type) {
    selectedCategory = type;
    notifyListeners();
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
