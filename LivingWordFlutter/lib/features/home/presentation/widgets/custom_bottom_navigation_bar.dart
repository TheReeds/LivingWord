import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';// Asegúrate de importar el AuthProvider

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;
    final hasUsersReadPermission = user?.permissions.contains('PERM_USERS_READ') ?? false;
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;

    // Verifica si el usuario tiene acceso para ver la opción "Users"
    final canViewUsers = hasUsersReadPermission || hasAdminAccess;

    // Lista de items base
    final items = [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: 'Home',
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.article_outlined),
        activeIcon: const Icon(Icons.article),
        label: 'Ministries',
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.event_outlined),
        activeIcon: const Icon(Icons.event),
        label: 'Events',
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.person_outline),
        activeIcon: const Icon(Icons.person),
        label: 'Profile',
        backgroundColor: theme.colorScheme.surfaceVariant,
      ),
    ];
    if (canViewUsers) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.group_outlined),
          activeIcon: const Icon(Icons.group),
          label: 'Users',
          backgroundColor: theme.colorScheme.surfaceVariant,
        ),
      );
    }

    return BottomNavigationBar(
      currentIndex: navigationProvider.currentIndex,
      onTap: navigationProvider.setIndex,
      type: BottomNavigationBarType.shifting,
      backgroundColor: theme.colorScheme.background,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey[500],
      elevation: 10,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: items,
    );
  }
}
