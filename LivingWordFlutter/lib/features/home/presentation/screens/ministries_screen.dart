import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/providers/auth_provider.dart';
import '../widgets/ministries/ministry_explanation_card.dart';
import '../widgets/ministries/ministry_option_card.dart';
import '../widgets/ministries/user_ministry_card.dart';
import 'ministries/manage_ministries_screen.dart';
import 'ministries/ministry_survey_data_screen.dart';
import 'ministries/ministry_survey_screen.dart';
import 'ministries/view_ministries_screen.dart';


class MinistriesScreen extends StatelessWidget {
  const MinistriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hasAdminAccess = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;
    final hasMinistryWrite = user?.permissions.contains('PERM_MINISTRY_WRITE') ?? false;
    final showManageOptions = hasAdminAccess || hasMinistryWrite;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Calcula el número de columnas basado en el ancho de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : 2;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MinistryExplanationCard(),
            const SizedBox(height: 32),

            if (user?.ministry != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Current Ministry',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              UserMinistryCard(ministry: user!.ministry!),
              const SizedBox(height: 32),
            ],

            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Ministry Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: screenWidth < 600 ? 2.5 : 0.85,
              children: [
                _buildMinistryOptionCard(
                  context,
                  'Ministry Survey',
                  'Express your interest in joining different ministries',
                  Icons.assignment_outlined,
                  Colors.blue,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MinistrySurveyScreen(),
                    ),
                  ),
                ),

                _buildMinistryOptionCard(
                  context,
                  'View Ministries',
                  'Explore all church ministries and their leaders',
                  Icons.visibility_outlined,
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewMinistriesScreen(),
                    ),
                  ),
                ),

                if (showManageOptions) ...[
                  _buildMinistryOptionCard(
                    context,
                    'Manage Ministries',
                    'Create, edit, and manage church ministries',
                    Icons.admin_panel_settings_outlined,
                    Colors.orange,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManageMinstriesScreen(),
                      ),
                    ),
                  ),

                  _buildMinistryOptionCard(
                    context,
                    'Survey Data',
                    'View and analyze ministry survey responses',
                    Icons.analytics_outlined,
                    Colors.purple,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MinistrySurveyDataScreen(),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinistryOptionCard(
      BuildContext context,
      String title,
      String description,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isDarkMode
                    ? color.withOpacity(0.2)
                    : color.withOpacity(0.1),
                isDarkMode
                    ? color.withOpacity(0.05)
                    : color.withOpacity(0.05),
              ],
            ),
          ),
          padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
          child: isSmallScreen
              ? Row(
            children: [
              Icon(icon, size: 36.0, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDarkMode ? Colors.grey[400] : Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48.0, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDarkMode ? Colors.grey[400] : Colors.black54,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}