import 'package:flutter/material.dart';
import '../widgets/active_sermon_banner.dart';
import '../widgets/dashboard_option_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de sermón destacado
            const ActiveSermonBanner(
              isActive: true,
              title: "God our Shepherd",
              time: "10:00 AM",
              date: "28 Oct, 2024",
            ),
            const SizedBox(height: 32),
            // Título de recursos
            Text(
              'Resources',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 20),
            // Tarjetas de opciones en formato Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _dashboardOptions.length,
              itemBuilder: (context, index) {
                final option = _dashboardOptions[index];
                return DashboardOptionCard(
                  title: option['title'] as String,
                  icon: option['icon'] as IconData,
                  route: option['route'] as String,
                  gradientColors: option['gradientColors'] as List<Color>,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Lista de opciones de Dashboard con detalles de cada tarjeta
  static final List<Map<String, dynamic>> _dashboardOptions = [
    {
      'title': 'Videos',
      'icon': Icons.video_library,
      'route': '/videos',
      'gradientColors': [Color(0xFF6448FE), Color(0xFF5FC6FF)],
    },
    {
      'title': 'Newsletters',
      'icon': Icons.newspaper,
      'route': '/newsletters',
      'gradientColors': [Color(0xFFFF5E7E), Color(0xFFFF9D6C)],
    },
    {
      'title': 'Contacts',
      'icon': Icons.contact_phone,
      'route': '/contacts',
      'gradientColors': [Color(0xFF46A55F), Color(0xFF69C576)],
    },
    {
      'title': 'Prayer Requests',
      'icon': Icons.how_to_vote,
      'route': '/prayer-requests',
      'gradientColors': [Color(0xFFFFBD59), Color(0xFFFF9D7C)],
    },
    {
      'title': 'Sermon Notes',
      'icon': Icons.edit_note,
      'route': '/sermon-notes',
      'gradientColors': [Color(0xFF4E429A), Color(0xFF6C72CB)],
    },
    {
      'title': 'Gift Assessments',
      'icon': Icons.card_giftcard,
      'route': '/gift-assessment',
      'gradientColors': [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],
    },
  ];
}
