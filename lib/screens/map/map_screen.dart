import 'package:ansim_app/constansts/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

class _MapScreenContent extends StatelessWidget {
  const _MapScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    return Scaffold(
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // 1. 배경이 되는 지도
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: viewModel.currentLocation!,
                    zoom: 15.0,
                  ),
                  onMapCreated: viewModel.onMapCreated,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // 커스텀 버튼 사용을 위해 끔
                  zoomControlsEnabled: false,
                ),

                // 2. 상단 검색 및 카테고리 영역
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildTopSearchBar(),
                        _buildCategoryChips(viewModel),
                      ],
                    ),
                  ),
                ),

                // 3. 하단 중앙 '신고하기' 버튼
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildReportButton(),
                  ),
                ),

                // 4. 우측 하단 컨트롤러 레이아웃
                Positioned(
                  bottom: 100,
                  right: 16,
                  child: _buildMapControls(viewModel),
                ),
              ],
            ),
    );
  }

  // 상단 검색바 위젯
  Widget _buildTopSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          const Text("장소, 주소 검색", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // 카테고리 칩 리스트
  Widget _buildCategoryChips(MapViewModel viewModel) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: viewModel.categories.length,
        itemBuilder: (context, index) {
          bool isSelected = viewModel.selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => viewModel.onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: Chip(
                backgroundColor: isSelected ? AnsimColor.primary : Colors.white,
                label: Text(
                  viewModel.categories[index],
                  style:
                      TextStyle(color: isSelected ? Colors.white : Colors.black),
                ),
                side: BorderSide.none,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 신고하기 버튼
  Widget _buildReportButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: SvgPicture.asset('assets/icons/camera.svg'),
        label: const Text("신고하기",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AnsimColor.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0, // Container의 boxShadow를 사용하기 위해 기본 elevation 제거
        ),
      ),
    );
  }

  // 우측 맵 컨트롤 버튼들
  Widget _buildMapControls(MapViewModel viewModel) {
    return Column(
      children: [
        _mapIconButton(Icons.bookmark_border, () {}),
        const SizedBox(height: 8),
        _mapIconButton(Icons.add, viewModel.zoomIn),
        _mapIconButton(Icons.remove, viewModel.zoomOut),
        const SizedBox(height: 8),
        _mapIconButton(Icons.my_location, viewModel.moveToCurrentLocation),
      ],
    );
  }

  Widget _mapIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: FloatingActionButton.small(
        heroTag: null, // 여러개일 경우 heroTag 충돌 방지
        onPressed: onPressed,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        child: Icon(icon),
      ),
    );
  }
}
