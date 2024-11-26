import 'package:flutter/material.dart';

class MinistryExplanationCard extends StatelessWidget {
  const MinistryExplanationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.church, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'What is a Ministry?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'At Living Word Adventist Church, ministries are specialized groups dedicated to serving specific needs within our church and community. Each ministry represents an opportunity to use your God-given talents to serve others and grow spiritually.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
