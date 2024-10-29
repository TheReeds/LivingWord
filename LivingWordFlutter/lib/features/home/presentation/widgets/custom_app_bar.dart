import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final VoidCallback onBackPressed;
  final VoidCallback onLogout;

  const CustomAppBar({
    Key? key,
    required this.user,
    required this.onBackPressed,
    required this.onLogout,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.name ?? '',
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            '${user?.ministry ?? 'Sin ministerio'} - ${user?.role ?? ''}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],
    );
  }
}