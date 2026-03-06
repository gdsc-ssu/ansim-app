import 'package:ansim_app/common/widgets/ansim_button.dart';
import 'package:ansim_app/constansts/constants.dart';
import 'package:ansim_app/screens/map/map_view_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel 구독 (listen: false는 버튼 클릭 등에서만 사용)
    final viewModel = context.watch<MapViewModel>();

    return Stack(
      children: [
        // 1. 배경 구글 맵
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: viewModel.initialPosition,
            zoom: 15,
          ),
          onMapCreated: viewModel.onMapCreated,
          markers: viewModel.markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // 2. 상단 레이어 (검색바 + 필터)
        SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 8),
              _buildCategoryChips(viewModel),
            ],
          ),
        ),

        // 3. 하단 신고하기 버튼 (중앙 하단)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              width: 160,
              child: AnsimButton(
                text: '신고하기',
                onPressed: () {
                  print("신고하기 클릭");
                },
              ),
            ),
          ),
        ),

        // 4. 우측 지도 컨트롤 (현재 위치 버튼 등)
        Positioned(
          right: 16,
          bottom: 100,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {},
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // 검색바 위젯 분리
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '장소, 주소 검색',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 필터 칩 리스트
  Widget _buildCategoryChips(MapViewModel viewModel) {
    final categories = ['전체', '싱크홀', '도로파손', '시설물', '기타'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = viewModel.selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => viewModel.selectCategory(category),
              backgroundColor: Colors.white,
              selectedColor: Colors.blue.shade100,
              checkmarkColor: Colors.blue,
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.blue : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}