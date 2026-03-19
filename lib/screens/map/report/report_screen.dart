import 'dart:io';
import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';
import 'package:ansim_app/common/widgets/ansim_button.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/common/widgets/basic_app_bar.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/map/report/report_view_model.dart';
import 'package:camera/camera.dart'; // XFile 사용을 위해 추가
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatefulWidget {
  final XFile image; // 1. 이전 뷰에서 넘겨받은 이미지

  const ReportScreen({super.key, required this.image});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  void initState() {
    super.initState();
    // 2. 화면이 생성될 때 ViewModel에 이미지를 저장합니다.
    // 만약 ReportViewModel이 이미 촬영 시점에 이미지를 가지고 있다면 생략 가능하지만,
    // 명확한 데이터 전달을 위해 여기서 한 번 더 세팅해주는 것이 안전합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportViewModel>().setImage(widget.image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ReportViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BasicAppBar(title: "신고 내용 확인"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 3. 넘겨받은 widget.image를 사용하여 즉시 표시
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(widget.image.path),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoBanner(),
            const SizedBox(height: 24),
            _buildSectionTitle("위험 유형"),
            _buildTypeSelector(viewModel),
            const SizedBox(height: 24),
            _buildSectionTitle("위험도"),
            _buildLevelSelector(viewModel),
            const SizedBox(height: 24),
            _buildSectionTitle("위치"),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    // ViewModel의 address를 반영 (AI 분석 결과가 반영된 주소)
                    controller: TextEditingController(text: viewModel.address),
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                _buildLocationButton(),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("상세 설명 (선택)"),
            _buildTextField(
              controller: viewModel.descriptionController,
              hint: "현장 상황을 자세히 적어주세요",
              maxLines: 4,
            ),
            const SizedBox(height: 40),
            AnsimButton(
              text: "제보하기",
              onPressed: () async {
                final success = await viewModel.submitReport();
                if (success && context.mounted) {
                  context.go(Paths.map);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

  // --- UI 컴포넌트 메서드들 ---

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF2196F3), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "AI가 자동으로 분석한 결과입니다. 수정할 수 있어요.",
              style: AnsimTextStyle.buttonB2.copyWith(color: AnsimColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AnsimTextStyle.captionC1,
      ),
    );
  }

Widget _buildTypeSelector(ReportViewModel viewModel) {
  // HazardType 모델에서 정의한 라벨 리스트를 가져옵니다.
  final categories = HazardType.reportLabels;

  return Wrap(
    spacing: 8.0,      // 가로 간격
    runSpacing: 8.0,   // 줄바꿈 시 세로 간격
    children: categories.map((label) {
      final isSelected = viewModel.selectedTypeStr == label;

      return ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            viewModel.setType(label);
          }
        },
        selectedColor: AnsimColor.primary, // 선택 시 배경색
        labelStyle: AnsimTextStyle.buttonB2.copyWith(
          color: isSelected ? Colors.white : AnsimColor.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
        backgroundColor: AnsimColor.bgSecondary, // 미선택 시 배경색
      );
    }).toList(),
  );
}

Widget _buildLevelSelector(ReportViewModel viewModel) {
  // Enum 내부에 정의한 리스트를 바로 가져옵니다.
  final levels = HazardLevel.reportLevels;

  return Row(
    children: levels.map((level) {
      final isSelected = viewModel.selectedLevelStr == level.koLabel;

      // 색상 결정 로직
      Color activeColor;
      switch (level) {
        case HazardLevel.HIGH:
          activeColor = const Color(0xFFFF4D4D);
          break;
        case HazardLevel.MEDIUM:
          activeColor = const Color(0xFFFFB347);
          break;
        case HazardLevel.LOW:
          activeColor = const Color(0xFF4CAF50);
          break;
        default:
          activeColor = AnsimColor.primary;
      }

      return Expanded(
        child: GestureDetector(
          onTap: () => viewModel.setLevel(level.koLabel),
          child: Container(
            margin: EdgeInsets.only(right: level == levels.last ? 0 : 8),
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : AnsimColor.bgSecondary,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              level.koLabel,
              style: AnsimTextStyle.buttonB2.copyWith(
                color: isSelected ? Colors.white : AnsimColor.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildTextField({required TextEditingController controller, String? hint, int maxLines = 1, bool readOnly = false}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      style: AnsimTextStyle.bodyB2,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AnsimTextStyle.bodyB2.copyWith(color: AnsimColor.textSecondary),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLocationButton() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: IconButton(icon: const Icon(Icons.location_on_outlined), onPressed: () {}),
    );
  }
