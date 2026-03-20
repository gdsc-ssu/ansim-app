import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:ansim_app/common/widgets/basic_app_bar.dart';
import 'package:ansim_app/constansts/colors.dart';
import 'package:ansim_app/data/di/get_it_locator.dart';
import 'package:ansim_app/screens/alarm/alarm_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlarmScreen extends StatelessWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: getIt<AlarmViewModel>(),
      child: const _AlarmScreenContent(),
    );
  }
}

class _AlarmScreenContent extends StatelessWidget {
  const _AlarmScreenContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AlarmViewModel>();

    return Scaffold(
      backgroundColor: AnsimColor.bgDefault,
      appBar: BasicAppBar(
        title: '알림',
        showBackButton: false,
        actions: viewModel.unreadCount > 0
            ? [
                TextButton(
                  onPressed: viewModel.markAllAsRead,
                  child: Text(
                    '모두 읽음',
                    style: AnsimTextStyle.captionC1.copyWith(
                      color: AnsimColor.primary,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.items.isEmpty
              ? Center(
                  child: Text(
                    '알림이 없습니다',
                    style: AnsimTextStyle.bodyB2.copyWith(
                      color: AnsimColor.textHint,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: viewModel.items.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, thickness: 1, color: AnsimColor.border),
                  itemBuilder: (context, index) {
                    final item = viewModel.items[index];
                    return _NotificationTile(
                      item: item,
                      onTap: () => viewModel.markAsRead(item.id),
                    );
                  },
                ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AlarmItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isUnread ? const Color(0xFFF0F7FF) : AnsimColor.bgDefault,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: item.iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.title, style: AnsimTextStyle.bodyB2),
                      Text(
                        item.timeAgo,
                        style: AnsimTextStyle.captionC1
                            .copyWith(color: AnsimColor.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AnsimTextStyle.captionC1.copyWith(
                      color: AnsimColor.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.location,
                      style: AnsimTextStyle.captionC1
                          .copyWith(color: AnsimColor.textHint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
