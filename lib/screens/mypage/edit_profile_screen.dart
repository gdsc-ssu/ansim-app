import 'package:ansim_app/common/widgets/ansim_button.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/common/widgets/basic_app_bar.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/screens/mypage/mypage_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditProfileScreen extends StatefulWidget {
  final MyPageViewModel viewModel;

  const EditProfileScreen({super.key, required this.viewModel});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.viewModel.name == '사용자' ? '' : widget.viewModel.name,
    );
    _addressController = TextEditingController(
      text: widget.viewModel.address == '주소 미설정' ? '' : widget.viewModel.address,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const BasicAppBar(title: '프로필 편집'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 프로필 이미지
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: AnsimColor.bgSecondary,
                            backgroundImage: widget.viewModel.profileImage != null
                                ? NetworkImage(widget.viewModel.profileImage!)
                                : null,
                            child: widget.viewModel.profileImage == null
                                ? const Icon(Icons.person, size: 48, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AnsimColor.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 이름
                    _buildTextField(
                      label: '이름',
                      controller: _nameController,
                      hint: '이름을 입력하세요',
                    ),
                    const SizedBox(height: 20),

                    // 주소
                    _buildTextField(
                      label: '주소',
                      controller: _addressController,
                      hint: '주소를 입력하세요',
                    ),
                  ],
                ),
              ),
            ),

            // 저장 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: AnsimButton(
                text: _isSaving ? '저장 중...' : '저장',
                onPressed: _isSaving ? () {} : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AnsimTextStyle.captionC1),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: AnsimTextStyle.bodyB2,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AnsimTextStyle.bodyB2.copyWith(color: AnsimColor.textHint),
            filled: true,
            fillColor: AnsimColor.bgSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await widget.viewModel.updateProfile(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
