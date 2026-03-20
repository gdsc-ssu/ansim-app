import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';
import 'package:ansim_app/common/widgets/custom_maker.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/data/dto/response/report_response.dart';
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
    return const _MapScreenContent();
  }
}

class _MapScreenContent extends StatefulWidget {
  const _MapScreenContent();

  @override
  State<_MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<_MapScreenContent> {
  int _markerLoadGeneration = 0;
  List _lastLoadedModels = const [];
  HazardType? _lastSelectedCategory;
  ReportResponse? _lastShownReport;
  final Map<HazardLevel, BitmapDescriptor> _iconCache = {};
  final Map<HazardLevel, Future<BitmapDescriptor>> _iconPending = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    context.read<MapViewModel>().removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    final viewModel = context.read<MapViewModel>();
    final report = viewModel.selectedReport;
    if (report != null && report != _lastShownReport) {
      _lastShownReport = report;
      _showReportBottomSheet(report);
    }
  }

  void _showReportBottomSheet(ReportResponse report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReportBottomSheet(report: report),
    ).whenComplete(() {
      _lastShownReport = null;
      if (mounted) context.read<MapViewModel>().clearSelectedReport();
    });
  }

  Future<BitmapDescriptor> _getIcon(HazardLevel level) {
    if (_iconCache.containsKey(level)) return Future.value(_iconCache[level]!);
    return _iconPending.putIfAbsent(level, () async {
      final icon = await widgetToMarkerIcon(customMarker(level), context);
      _iconCache[level] = icon;
      _iconPending.remove(level);
      return icon;
    });
  }

  Future<void> _loadMarkers(MapViewModel viewModel) async {
    final generation = ++_markerLoadGeneration;

    final filtered = viewModel.selectedCategory == null
        ? viewModel.markerModels
        : viewModel.markerModels
            .where((m) => m.hazardType == viewModel.selectedCategory)
            .toList();

    if (!mounted || generation != _markerLoadGeneration) return;

    // 필요한 레벨 아이콘 순차 생성 (메모리 부하 방지)
    final neededLevels = filtered.map((m) => m.hazardLevel).toSet();
    for (final level in neededLevels) {
      if (!mounted || generation != _markerLoadGeneration) return;
      await _getIcon(level);
    }

    if (!mounted || generation != _markerLoadGeneration) return;

    final markers = filtered.map((dto) => Marker(
      markerId: MarkerId(dto.id),
      position: LatLng(dto.latitude, dto.longitude),
      icon: _iconCache[dto.hazardLevel]!,
      infoWindow: InfoWindow(title: dto.hazardLevel.koLabel),
      onTap: () => viewModel.fetchReport(dto.id),
    )).toSet();

    if (mounted && generation == _markerLoadGeneration) viewModel.setMarkers(markers);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MapViewModel>();

    // markerModels가 바뀔 때마다 마커 재변환
    if (!viewModel.isLoading &&
        viewModel.currentLocation != null &&
        (viewModel.markerModels != _lastLoadedModels ||
            viewModel.selectedCategory != _lastSelectedCategory)) {
      _lastLoadedModels = viewModel.markerModels;
      _lastSelectedCategory = viewModel.selectedCategory;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMarkers(viewModel);
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
            onCameraIdle: () async {
              final zoom = await viewModel.mapController?.getZoomLevel();
              if (zoom != null) viewModel.onCameraIdle(zoom);
            },
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
    // null = 전체, 나머지는 HazardType (NONE 제외)
    final categories = <HazardType?>[
      null,
      ...HazardType.values.where((t) => t != HazardType.NONE),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final type = categories[index];
          final isSelected = viewModel.selectedCategory == type;
          final label = type == null ? "전체" : type.koLabel;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(label),
              onSelected: (_) => viewModel.onCategorySelected(type),
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

class _ReportBottomSheet extends StatelessWidget {
  final ReportResponse report;

  const _ReportBottomSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 레벨 뱃지 + 유형
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: report.hazardLevel.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  report.hazardLevel.koLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                report.hazardType.koLabel,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 출처 (report / safetyMungoReport)
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(report.source, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),

          // 설명
          if (report.report?.description != null && report.report!.description!.isNotEmpty) ...[
            Text(report.report!.description!, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
          ],

          // 좋아요 / 댓글 / 날짜
          Row(
            children: [
              const Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${report.likeCount}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 12),
              const Icon(Icons.comment_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text('${report.commentCount}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Spacer(),
              Text(
                '${report.createdAt.year}.${report.createdAt.month.toString().padLeft(2, '0')}.${report.createdAt.day.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}