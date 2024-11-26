import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final profileImageUrl = user?.photoUrl != null
        ? ApiConstants.profileImageUrl(user!.photoUrl)
        : null;

    return AppBar(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[900]
          : Colors.white,
      elevation: 1,
      titleSpacing: 0, // Reduce el espacio entre el leading y el título
      leading: Container(
        padding: const EdgeInsets.only(left: 12.0),
        child: Hero(
          tag: 'profile_image_${user?.id}',
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[200],
            child: ClipOval(
              child: profileImageUrl != null
                  ? Image.network(
                profileImageUrl,
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_profile.png',
                    fit: BoxFit.cover,
                    width: 36,
                    height: 36,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.blue[200],
                    ),
                  );
                },
              )
                  : Image.asset(
                'assets/images/default_profile.png',
                fit: BoxFit.cover,
                width: 36,
                height: 36,
              ),
            ),
          ),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${user?.name ?? 'Username'} ${user?.lastname ?? 'UserLastName'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1DA1F2),
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2), // Espaciado fino entre textos
            Text(
              '${user?.ministry ?? 'Ministerio no asignado'} - ${user?.role ?? 'Rol no asignado'}',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.grey[600],
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1DA1F2),
            size: 22, // Tamaño ajustado
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: isDarkMode ? 'Modo claro' : 'Modo oscuro',
        ),
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.red[300]
                : Colors.redAccent,
            size: 22, // Tamaño ajustado
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          onPressed: onLogout,
          tooltip: 'Logout',
        ),
        const SizedBox(width: 4), // Padding final
      ],
    );
  }
}