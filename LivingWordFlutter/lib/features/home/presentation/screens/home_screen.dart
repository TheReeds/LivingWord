import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../widgets/custom_app_bar.dart';
import 'dashboard_screen.dart';
import 'bulletins_screen.dart';
import 'events_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NavigationProvider(),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();
    final user = context.watch<AuthProvider>().user;

    // Lista de pantallas para el bottom navigation
    final screens = [
      const DashboardScreen(),
      const BulletinsScreen(),
      const EventsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        user: user,
        onLogout: () {
          context.read<AuthProvider>().logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: IndexedStack(
        index: navigationProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
