import 'package:ansim_app/common/widgets/atom/texts/texts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const BasicAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
        onPressed: () => context.pop(),
      )
          : null,
      title: Text(
        title,
        style: AnsimTextStyle.buttonB3
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}