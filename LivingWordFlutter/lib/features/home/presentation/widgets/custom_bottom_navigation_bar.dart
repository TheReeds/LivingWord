import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_provider.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final theme = Theme.of(context);

    return BottomNavigationBar(
      currentIndex: navigationProvider.currentIndex,
      onTap: navigationProvider.setIndex,
      type: BottomNavigationBarType.shifting, // Transición suave entre tabs
      backgroundColor: theme.colorScheme.background,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: Colors.grey[500],
      elevation: 10,
      selectedFontSize: 14,
      unselectedFontSize: 12,
      items: [
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
      ],
    );
  }
}
