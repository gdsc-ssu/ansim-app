import 'package:ansim_app/data/repository/local/secure_storage_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  final SecureStorageRepository _secureStorage = SecureStorageRepository();

  bool isLoading = true;
  LatLng? currentLocation;
  GoogleMapController? mapController;
  int currentIndex = 0;
  int selectedCategoryIndex = 0;
  final List<String> categories = ["전체", "싱크홀", "도로파손", "붕괴위험", "시설물"];

  Set<Marker> markers = {};

  void setMarkers(Set<Marker> newMarkers) {
    markers = newMarkers;
    notifyListeners();
  }

  MapViewModel() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.high));
      currentLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      // Default location (e.g., Seoul) if failed to get location
      currentLocation = const LatLng(37.5665, 126.9780);
      print("Error getting location: $e");
    } finally {
      isLoading = false;
      notifyListeners();
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

  Future<void> moveToCurrentLocation() async {
    if (currentLocation != null) {
      // 위치 업데이트가 한 번 더 필요한 경우를 위해 현재 위치를 다시 가져올 수도 있지만
      // 일단은 기존 currentLocation으로 이동합니다.
      try {
        Position position = await Geolocator.getCurrentPosition(
            locationSettings:
                const LocationSettings(accuracy: LocationAccuracy.high));
        currentLocation = LatLng(position.latitude, position.longitude);
      } catch (e) {
        print("Error getting location: $e");
      }

      mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation!,
            zoom: 15.0,
          ),
        ),
      );
    }
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

  Future<bool> checkIsLoggedIn() async {
    return await _secureStorage.readIsLoggedIn();
  }
}
