import 'dart:io';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/common/widgets/basic_app_bar.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/map/report/report_view_model.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiAnalysisScreen extends StatefulWidget {
  final XFile image;
  final ReportViewModel viewModel;

  const AiAnalysisScreen({
    super.key,
    required this.image,
    required this.viewModel,
  });

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  int _currentStep = 0;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onAnalysisChanged);
    _startStepAnimation();
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onAnalysisChanged);
    super.dispose();
  }

  void _onAnalysisChanged() {
    if (!mounted || _navigated) return;
    if (!widget.viewModel.isAnalyzing) {
      // AI 분석 완료 → 마지막 단계 표시 후 이동
      setState(() => _currentStep = 4);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_navigated) {
          _navigated = true;
          context.push(
            Paths.report,
            extra: {
              'image': widget.image,
              'viewModel': widget.viewModel,
            },
          );
        }
      });
    }
  }

  Future<void> _startStepAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _currentStep = 1);

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _currentStep = 2);

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _currentStep = 3);

    // 애니메이션이 끝났는데 분석도 이미 완료된 경우 바로 이동
    if (!widget.viewModel.isAnalyzing && !_navigated) {
      _onAnalysisChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BasicAppBar(title: "AI 분석중"),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // 1. 상단 촬영된 이미지 카드
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(widget.image.path),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 2. 로딩 인디케이터
          if (_currentStep < 4)
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
            )
          else
            const SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
            ),

          const SizedBox(height: 24),

          // 3. 안내 텍스트
          Text(
            _currentStep < 4 ? "사진을 분석하고 있어요" : "분석이 완료되었어요",
            style: AnsimTextStyle.bodyB1,
          ),
          const SizedBox(height: 8),
          if (_currentStep < 4)
            Text(
              "AI가 위험 유형과 위험도를\n자동으로 분류합니다",
              textAlign: TextAlign.center,
              style: AnsimTextStyle.bodyB2.copyWith(color: AnsimColor.textSecondary),
            ),

          const SizedBox(height: 40),

          // 4. 진행 단계 리스트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  _buildAnalysisStep("이미지 인식 완료", isDone: _currentStep > 0, isActive: _currentStep == 0),
                  _buildAnalysisStep("위험 유형 분류 중...", isDone: _currentStep > 1, isActive: _currentStep == 1),
                  _buildAnalysisStep("위험도 평가", isDone: _currentStep > 2, isActive: _currentStep == 2),
                  _buildAnalysisStep("위치 태깅", isDone: _currentStep > 3, isActive: _currentStep == 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 단계별 아이콘 및 텍스트 위젯
  Widget _buildAnalysisStep(String title, {required bool isDone, required bool isActive}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? const Color(0xFF4CAF50)
                  : (isActive ? const Color(0xFF2196F3) : Colors.grey.shade200),
            ),
            child: Icon(
              isDone ? Icons.check : (isActive ? Icons.circle : Icons.circle),
              size: isDone ? 18 : 10,
              color: isDone || isActive ? Colors.white : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: AnsimTextStyle.buttonB2,
          ),
        ],
      ),
    );
  }
}
