import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/widgets/custom_maker.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ansim_app/screens/map/map_view_model.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapViewModel(),
      child: const _MapScreenContent(),
    );
  }
}

class _MapScreenContent extends StatefulWidget {
  const _MapScreenContent();

  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  bool _markersLoaded = false;

  Future<void> _loadTestMarkers(MapViewModel viewModel) async {
    final base = viewModel.currentLocation!;

    // 테스트용 마커 데이터: 현재 위치 주변에 각 HazardLevel 하나씩
    final testData = [
      (LatLng(base.latitude + 0.001, base.longitude), HazardLevel.HIGH),
      (LatLng(base.latitude, base.longitude + 0.001), HazardLevel.MEDIUM),
      (LatLng(base.latitude - 0.001, base.longitude), HazardLevel.LOW),
      (LatLng(base.latitude, base.longitude - 0.001), HazardLevel.UNKNOWN),
    ];

    final markers = <Marker>{};
    for (var i = 0; i < testData.length; i++) {
      if (!mounted) return;
      final (latLng, level) = testData[i];
      final icon = await widgetToMarkerIcon(customMarker(level), context);
      markers.add(Marker(
        markerId: MarkerId('test_marker_$i'),
        position: latLng,
        icon: icon,
        infoWindow: InfoWindow(title: level.koLabel),
      ));
    }

    if (mounted) viewModel.setMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    // watch allows the widget to rebuild when notifyListeners() is called in VM
    final viewModel = context.watch<MapViewModel>();

    // 위치 로딩 완료 시 마커 생성
    if (!viewModel.isLoading && viewModel.currentLocation != null && !_markersLoaded) {
      _markersLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadTestMarkers(viewModel);
      });
    }

    return Scaffold(
      body: viewModel.isLoading || viewModel.currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // 1. Base Map Layer
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: viewModel.currentLocation!,
              zoom: 15.0,
            ),
            onMapCreated: viewModel.onMapCreated,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: viewModel.markers,
          ),

          // 2. Top UI (Search & Categories)
          SafeArea(
            child: Column(
              children: [
                _buildTopSearchBar(),
                _buildCategoryChips(viewModel),
              ],
            ),
          ),

          // 3. Floating Controls (Zoom & Location)
          Positioned(
            bottom: 110, // Adjusted to sit above the report button area
            right: 16,
            child: _buildMapControls(viewModel),
          ),

          // 4. Center Bottom Report Button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _buildReportButton(context, viewModel), // Fixed parameters
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Text("장소, 주소 검색", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  /// 카테고리 체크 리스트
  Widget _buildCategoryChips(MapViewModel viewModel) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          final isSelected = viewModel.selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(viewModel.categories[index]),
              onSelected: (_) => viewModel.onCategorySelected(index),
              backgroundColor: Colors.white,
              selectedColor: AnsimColor.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AnsimColor.primary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, MapViewModel viewModel) { // context 추가
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AnsimColor.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          // 1. 로그인 상태 확인
          final isLoggedIn = await viewModel.checkIsLoggedIn();

          if (isLoggedIn) {
            // 2. 로그인 상태면 신고 페이지로 이동 (경로명은 프로젝트 설정에 맞게 수정하세요)
            context.push(Paths.camera);
          } else {
            // 3. 로그인이 안 되어 있으면 로그인 페이지로 이동
            // 사용자에게 알림을 주고 싶다면 여기서 간단한 SnackBar를 띄울 수도 있습니다.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('신고를 위해 로그인이 필요합니다.')),
            );
            context.push(Paths.login);
          }
        },
        icon: SvgPicture.asset(
          'assets/icons/camera.svg',
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
        label: const Text("신고하기"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AnsimColor.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
  Widget _buildMapControls(MapViewModel viewModel) {
    return Column(
      children: [
        _mapIconButton(Icons.add, viewModel.zoomIn),
        const SizedBox(height: 8),
        _mapIconButton(Icons.remove, viewModel.zoomOut),
        const SizedBox(height: 16),
        _mapIconButton(Icons.my_location, viewModel.moveToCurrentLocation),
      ],
    );
  }

  Widget _mapIconButton(IconData icon, VoidCallback onPressed, {bool isPrimary = false}) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      backgroundColor: isPrimary ? AnsimColor.primary : Colors.white,
      foregroundColor: isPrimary ? Colors.white : Colors.black87,
      child: Icon(icon),
    );
  }
}