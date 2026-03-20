import 'package:ansim_app/common/enums/hazard_level.dart';
import 'package:ansim_app/common/enums/hazard_type.dart';
import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/constansts/paths.dart';
import 'package:ansim_app/screens/mypage/edit_profile_screen.dart';
import 'package:ansim_app/screens/mypage/mypage_view_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyPageViewModel(),
      child: const _MyPageContent(),
    );
  }
}

class _MyPageContent extends StatelessWidget {
  const _MyPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MyPageViewModel>();

    if (viewModel.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AnsimColor.bgSecondary,
      appBar: AppBar(
        title: Text('마이페이지', style: AnsimTextStyle.headingH2),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildProfileSection(context, viewModel),
            const SizedBox(height: 8),
            _buildMyReportsSection(context, viewModel),
            const SizedBox(height: 8),
            _buildSettingsSection(viewModel),
            const SizedBox(height: 8),
            _buildLogoutButton(context, viewModel),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, MyPageViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AnsimColor.bgSecondary,
            backgroundImage: viewModel.profileImage != null
                ? NetworkImage(viewModel.profileImage!)
                : null,
            child: viewModel.profileImage == null
                ? const Icon(Icons.person, size: 32, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(viewModel.name, style: AnsimTextStyle.bodyB1),
                const SizedBox(height: 4),
                Text(
                  viewModel.email,
                  style: AnsimTextStyle.captionC1
                      .copyWith(color: AnsimColor.textSecondary),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14, color: AnsimColor.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      viewModel.address,
                      style: AnsimTextStyle.captionC1
                          .copyWith(color: AnsimColor.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(viewModel: viewModel),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMyReportsSection(
      BuildContext context, MyPageViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('내 신고 내역', style: AnsimTextStyle.bodyB1),
              Text(
                '${viewModel.myReports.length}건',
                style: AnsimTextStyle.bodyB2
                    .copyWith(color: AnsimColor.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (viewModel.myReports.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  '아직 신고한 내역이 없어요',
                  style: AnsimTextStyle.bodyB2
                      .copyWith(color: AnsimColor.textHint),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  viewModel.myReports.length > 5 ? 5 : viewModel.myReports.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = viewModel.myReports[index];
                return _buildReportItem(report);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    final hazardType =
        HazardType.fromString(report['hazardType'] as String?);
    final hazardLevel =
        HazardLevel.fromString(report['hazardLevel'] as String? ?? '');
    final description = report['description'] as String? ?? '';
    final createdAt = DateTime.tryParse(report['createdAt'] as String? ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: hazardLevel.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              hazardLevel.koLabel,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hazardType.koLabel, style: AnsimTextStyle.bodyB2),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: AnsimTextStyle.captionC1
                        .copyWith(color: AnsimColor.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (createdAt != null)
            Text(
              '${createdAt.month}.${createdAt.day}',
              style: AnsimTextStyle.captionC1
                  .copyWith(color: AnsimColor.textHint),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(MyPageViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('알림 설정', style: AnsimTextStyle.bodyB1),
          const SizedBox(height: 8),
          _buildSwitchTile(
            title: '주변 위험 알림',
            subtitle: '내 주변에 새로운 위험이 신고되면 알려드려요',
            value: viewModel.nearbyDangerAlert,
            onChanged: viewModel.toggleNearbyDangerAlert,
          ),
          const Divider(height: 1),
          _buildSwitchTile(
            title: '긴급 알림',
            subtitle: '긴급 재난 알림을 받아요',
            value: viewModel.emergencyAlert,
            onChanged: viewModel.toggleEmergencyAlert,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AnsimTextStyle.bodyB2),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AnsimTextStyle.captionC1
                      .copyWith(color: AnsimColor.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AnsimColor.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, MyPageViewModel viewModel) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading:
            const Icon(Icons.logout, color: Colors.red, size: 22),
        title: Text(
          '로그아웃',
          style: AnsimTextStyle.bodyB2.copyWith(color: Colors.red),
        ),
        onTap: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('로그아웃'),
              content: const Text('정말 로그아웃 하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child:
                      const Text('로그아웃', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await viewModel.logout();
            context.go(Paths.login);
          }
        },
      ),
    );
  }
}
