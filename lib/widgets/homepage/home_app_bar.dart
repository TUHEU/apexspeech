import 'package:flutter/material.dart';
import '../../helpers/app_colors.dart';

class HomePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomePageAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('APEX SPEECH'),
      centerTitle: true,
      backgroundColor: AppColors.surfaceDark,
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: AppColors.purpleLight),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }
}
