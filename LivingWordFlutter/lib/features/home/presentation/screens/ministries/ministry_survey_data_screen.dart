import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/models/ministry_model.dart';
import '../../../data/models/ministry_response_detail.dart';
import '../../../data/models/ministry_statistics.dart';
import '../../../providers/ministry_statistics_provider.dart';

class MinistrySurveyDataScreen extends StatefulWidget {
  const MinistrySurveyDataScreen({super.key});

  @override
  State<MinistrySurveyDataScreen> createState() => _MinistrySurveyDataScreenState();
}

class _MinistrySurveyDataScreenState extends State<MinistrySurveyDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MinistryStatisticsProvider>().loadMinistries();
    });
  }

  void _showStatistics(BuildContext context, MinistryModel ministry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _StatisticsBottomSheet(ministry: ministry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ministry Survey'),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 4,
        shadowColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: Text(
            'Statistics Overview',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
          ),
        ),
      ),
      body: Consumer<MinistryStatisticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: Shimmer.fromColors(
                baseColor: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                highlightColor: isDarkMode ? Colors.grey[600]! : Colors.grey[100]!,
                child: Container(
                  height: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  ),
                ),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            );
          }

          if (provider.ministries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_off, size: 48, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(height: 16),
                  Text(
                    'No ministries found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.ministries.length,
            itemBuilder: (context, index) {
              final ministry = provider.ministries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    ministry.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      ministry.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bar_chart, color: Colors.blueAccent),
                    onPressed: () => _showStatistics(context, ministry),
                    tooltip: 'View Statistics',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class _StatisticsBottomSheet extends StatefulWidget {
  final MinistryModel ministry;

  const _StatisticsBottomSheet({required this.ministry});

  @override
  State<_StatisticsBottomSheet> createState() => _StatisticsBottomSheetState();
}

class _StatisticsBottomSheetState extends State<_StatisticsBottomSheet> {
  String _selectedView = 'general';
  String _selectedResponse = 'YES';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() {
    final provider = context.read<MinistryStatisticsProvider>();
    switch (_selectedView) {
      case 'general':
        provider.loadStatistics(widget.ministry.id);
        break;
      case 'all':
        provider.loadAllResponses(widget.ministry.id);
        break;
      case 'specific':
        provider.loadResponsesByType(widget.ministry.id, _selectedResponse);
        break;
    }
  }

  Color _getResponseColor(BuildContext context, String response) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    switch (response) {
      case 'YES':
        return isDarkMode ? Colors.greenAccent : Colors.green;
      case 'NO':
        return isDarkMode ? Colors.redAccent : Colors.red;
      case 'MAYBE':
        return isDarkMode ? Colors.orangeAccent : Colors.orange;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Widget _buildGeneralStats(MinistryStatistics stats) {
    return Column(
      children: [
        _buildStatCard('Yes Responses', stats.yesCount, stats.yesUsers, 'YES'),
        _buildStatCard('No Responses', stats.noCount, stats.noUsers, 'NO'),
        _buildStatCard('Maybe Responses', stats.maybeCount, stats.maybeUsers, 'MAYBE'),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, List<String> users, String type) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getResponseColor(context, type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      color: _getResponseColor(context, type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (users.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Respondents',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...users.map((user) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(user),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesList(List<MinistryResponseDetail> responses) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: responses.length,
      itemBuilder: (context, index) {
        final response = responses[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getResponseColor(context, response.response).withOpacity(0.2),
              child: Icon(
                Icons.person,
                color: _getResponseColor(context, response.response),
              ),
            ),
            title: Text(
              response.fullName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getResponseColor(context, response.response).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                response.response,
                style: TextStyle(
                  color: _getResponseColor(context, response.response),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.ministry.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('General Stats', 'general'),
                          const SizedBox(width: 8),
                          _buildFilterChip('All Responses', 'all'),
                          const SizedBox(width: 8),
                          _buildFilterChip('By Response Type', 'specific'),
                        ],
                      ),
                    ),
                    if (_selectedView == 'specific') ...[
                      const SizedBox(height: 16),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildResponseFilterChip('YES'),
                            const SizedBox(width: 8),
                            _buildResponseFilterChip('NO'),
                            const SizedBox(width: 8),
                            _buildResponseFilterChip('MAYBE'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Consumer<MinistryStatisticsProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (provider.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${provider.error}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (_selectedView == 'general' && provider.currentStatistics != null) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: _buildGeneralStats(provider.currentStatistics!),
                      );
                    }

                    if ((_selectedView == 'all' || _selectedView == 'specific') &&
                        provider.responses.isNotEmpty) {
                      return SingleChildScrollView(
                        controller: scrollController,
                        child: _buildResponsesList(provider.responses),
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No data available',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return FilterChip(
      label: Text(label),
      selected: _selectedView == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedView = value;
            _loadStatistics();
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildResponseFilterChip(String value) {
    return FilterChip(
      label: Text(value),
      selected: _selectedResponse == value,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedResponse = value;
            _loadStatistics();
          });
        }
      },
      selectedColor: _getResponseColor(context, value).withOpacity(0.2),
      checkmarkColor: _getResponseColor(context, value),
    );
  }
}