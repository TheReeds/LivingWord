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
            const ActiveSermonBanner(
              isActive: true, // Esto vendría de tu backend
              title: "God our shepherd",
              time: "10:00 AM",
              date: "28 Oct, 2024",
            ),
            const SizedBox(height: 24),
            Text(
              'Resources',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: const [
                DashboardOptionCard(
                  title: 'Videos',
                  icon: Icons.video_library,
                  route: '/videos',
                  gradientColors: [Color(0xFF6448FE), Color(0xFF5FC6FF)],
                ),
                DashboardOptionCard(
                  title: 'Newsletters',
                  icon: Icons.newspaper,
                  route: '/newsletters',
                  gradientColors: [Color(0xFFFF5E7E), Color(0xFFFF9D6C)],
                ),
                DashboardOptionCard(
                  title: 'Contacts',
                  icon: Icons.contact_phone,
                  route: '/contacts',
                  gradientColors: [Color(0xFF46A55F), Color(0xFF69C576)],
                ),
                DashboardOptionCard(
                  title: 'Prayer Requests',
                  icon: Icons.how_to_vote,
                  route: '/prayer-requests',
                  gradientColors: [Color(0xFFFFBD59), Color(0xFFFF9D7C)],
                ),
                DashboardOptionCard(
                  title: 'Sermon notes',
                  icon: Icons.edit_note,
                  route: '/sermon-notes',
                  gradientColors: [Color(0xFF4E429A), Color(0xFF6C72CB)],
                ),
                DashboardOptionCard(
                  title: 'Gift Assessments',
                  icon: Icons.card_giftcard,
                  route: '/gift-assessment',
                  gradientColors: [Color(0xFFFF6B6B), Color(0xFFFF9F9F)],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}