import 'package:flutter/material.dart';
import '../../../auth/data/models/user_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final UserModel? user;
  final VoidCallback onLogout;

  const CustomAppBar({
    Key? key,
    required this.user,
    required this.onLogout,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[200],
          backgroundImage: user?.profileImageUrl != null
              ? NetworkImage(user!.profileImageUrl!)
              : AssetImage('assets/images/default_profile.png') as ImageProvider,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user?.name ?? 'Nombre de Usuario',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1DA1F2), // Azul tipo Twitter
              fontSize: 16,
            ),
          ),
          Text(
            '${user?.ministry ?? 'Ministerio no asignado'} - ${user?.role ?? 'Rol no asignado'}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Color(0xFF1DA1F2),
          ),
          onPressed: () {
            // Acción futura para notificaciones
          },
          tooltip: 'Notificaciones',
        ),
        IconButton(
          icon: const Icon(
            Icons.logout,
            color: Colors.redAccent,
          ),
          onPressed: onLogout,
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }
}
