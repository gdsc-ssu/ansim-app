import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapViewModel extends ChangeNotifier {
  bool isLoading = true;
  LatLng? currentLocation;
  GoogleMapController? mapController;
  int currentIndex = 0;

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

  void changeTab(int index) {
    currentIndex = index;
    notifyListeners();
  }
}
