import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  // 1. 네비게이션 상태
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  // 2. 지도 상태
  GoogleMapController? _mapController;

  // 초기 위치 (서울 시청 근처 예시)
  static const LatLng _initialPos = LatLng(37.5665, 126.9780);
  LatLng get initialPosition => _initialPos;

  // 마커 데이터
  final Set<Marker> _markers = {};
  Set<Marker> get markers => _markers;

  // 카테고리 필터 상태
  String _selectedCategory = '전체';
  String get selectedCategory => _selectedCategory;

  // 지도 생성 시 호출
  void onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _addSampleMarkers();
    notifyListeners();
  }

  // 카테고리 선택 시 호출
  void selectCategory(String category) {
    _selectedCategory = category;
    // TODO: 카테고리에 따른 마커 필터링 로직 추가 가능
    notifyListeners();
  }

  void _addSampleMarkers() {
    _markers.add(
      const Marker(
        markerId: MarkerId('sample_1'),
        position: LatLng(37.5665, 126.9780),
        infoWindow: InfoWindow(title: '위험 지역', snippet: '도로 파손 주의'),
      ),
    );
  }
}