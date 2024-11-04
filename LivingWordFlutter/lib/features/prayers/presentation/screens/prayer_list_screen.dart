import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/prayer_provider.dart';
import '../widgets/prayer_card.dart';

class PrayerListScreen extends StatefulWidget {
  const PrayerListScreen({Key? key}) : super(key: key);

  @override
  State<PrayerListScreen> createState() => _PrayerListScreenState();
}
class _PrayerListScreenState extends State<PrayerListScreen> {
  final TextEditingController _prayerController = TextEditingController();

  @override
  void dispose() {
    _prayerController.dispose();
    super.dispose();
  }
  int _currentPage = 0;
  final int _pageSize = 10;
  String _sortDir = 'desc';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Requests'),
        actions: [
          IconButton(
            icon: Icon(_sortDir == 'desc' ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() {
                _sortDir = _sortDir == 'desc' ? 'asc' : 'desc';
                _currentPage = 0; // Reset to first page
              });
              context.read<PrayerProvider>().loadPaginatedPrayers(
                page: _currentPage,
                sortDir: _sortDir,
              );
            },
            tooltip: _sortDir == 'desc' ? 'Newest First' : 'Oldest First',
          ),
        ],
      ),
      body: Consumer<PrayerProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.paginatedPrayers == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          final paginatedData = provider.paginatedPrayers;
          if (paginatedData == null) return const SizedBox();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: paginatedData.content.length,
                  itemBuilder: (context, index) {
                    final prayer = paginatedData.content[index];
                    return PrayerCard(prayer: prayer);
                  },
                ),
              ),
              if (!provider.isLoading) Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: !paginatedData.first ? () {
                        setState(() => _currentPage--);
                        provider.loadPaginatedPrayers(
                          page: _currentPage,
                          sortDir: _sortDir,
                        );
                      } : null,
                    ),
                    Text('${_currentPage + 1} / ${paginatedData.totalPages}'),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: !paginatedData.last ? () {
                        setState(() => _currentPage++);
                        provider.loadPaginatedPrayers(
                          page: _currentPage,
                          sortDir: _sortDir,
                        );
                      } : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePrayerDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreatePrayerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Prayer Request'),
        content: TextField(
          controller: _prayerController,
          decoration: const InputDecoration(
            hintText: 'Enter your prayer request...',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _prayerController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_prayerController.text.isNotEmpty) {
                try {
                  await context
                      .read<PrayerProvider>()
                      .createPrayer(_prayerController.text);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Prayer request created successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Error creating prayer request'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
                _prayerController.clear();
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
