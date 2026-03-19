import 'dart:io';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/common/widgets/basic_app_bar.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AiAnalysisScreen extends StatefulWidget {
  final XFile image;

  const AiAnalysisScreen({super.key, required this.image});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  // 분석 단계 상태 관리 (0: 이미지 인식, 1: 위험 분류, 2: 위험도 평가, 3: 위치 태깅)
  int _currentStep = 1;

  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  // API 호출 및 단계적 애니메이션 시뮬레이션
  Future<void> _startAnalysis() async {
    // 1. 이미지 인식 완료 (잠시 대기)
    await Future.delayed(const Duration(milliseconds: 800));

    // 2. 실제 서버 API 호출 (/api/analysis)
    try {
      // final response = await dio.post('/api/analysis', data: formData);

      // 응답 대기 중 진행 단계 변경 시뮬레이션
      await Future.delayed(const Duration(seconds: 1));
      setState(() => _currentStep = 2);

      await Future.delayed(const Duration(seconds: 1));
      setState(() => _currentStep = 3);

      context.push(
        Paths.report,
        extra: widget.image,
      );
    } catch (e) {
      // 에러 처리
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
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            ),
          ),

          const SizedBox(height: 24),

          // 3. 안내 텍스트
          const Text(
            "사진을 분석하고 있어요",
            style: AnsimTextStyle.bodyB1,
          ),
          const SizedBox(height: 8),
          Text(
            "AI가 위험 유형과 위험도를\n자동으로 분류합니다",
            textAlign: TextAlign.center,
            style: AnsimTextStyle.bodyB2.copyWith(color: AnsimColor.textSecondary),
          ),

          const SizedBox(height: 40),

          // 4. 진행 단계 리스트 (디자인 가이드 반영)
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
                  ? const Color(0xFF4CAF50) // 완료 시 녹색
                  : (isActive ? const Color(0xFF2196F3) : Colors.grey.shade200), // 진행중 파랑 / 대기 회색
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