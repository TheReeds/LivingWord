import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/ministry_provider.dart';

class ViewMinistriesScreen extends StatefulWidget {
  const ViewMinistriesScreen({super.key});

  @override
  State<ViewMinistriesScreen> createState() => _ViewMinistriesScreenState();
}

class _ViewMinistriesScreenState extends State<ViewMinistriesScreen> {
  bool _isFirstLoad = true;

  Future<void> _refreshMinistries(BuildContext context) async {
    try {
      await context.read<MinistryProvider>().loadMinistries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading ministries: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (_isFirstLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshMinistries(context);
        _isFirstLoad = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Ministry List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _refreshMinistries(context),
          ),
        ],
      ),
      body: Consumer<MinistryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.ministries.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (provider.error != null && provider.ministries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading ministries',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _refreshMinistries(context),
                    child: const Text('Reload'),
                  ),
                ],
              ),
            );
          }

          return const ViewMinistriesContent();
        },
      ),
    );
  }
}

class ViewMinistriesContent extends StatelessWidget {
  const ViewMinistriesContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<MinistryProvider>(
      builder: (context, ministryProvider, child) {
        if (ministryProvider.error != null) {
          return RefreshIndicator(
            onRefresh: () => context.read<MinistryProvider>().loadMinistries(),
            child: Stack(
              children: [
                ListView(),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar los ministerios',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ministryProvider.error!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDarkMode ? Colors.grey[300] : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.read<MinistryProvider>().loadMinistries(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (ministryProvider.isLoading) {
          return Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading ministries...',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[300] : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (ministryProvider.ministries.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<MinistryProvider>().loadMinistries(),
            child: Stack(
              children: [
                ListView(),
                Container(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 60,
                          color: isDarkMode ? Colors.grey[600] : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay ministerios disponibles',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.grey[300] : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
          child: RefreshIndicator(
            onRefresh: () => context.read<MinistryProvider>().loadMinistries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ministryProvider.ministries.length,
              itemBuilder: (context, index) {
                final ministry = ministryProvider.ministries[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // TODO: Navegar al detalle del ministerio
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ministry.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.info,
                                  color: Theme.of(context).primaryColor,
                                ),
                                onPressed: () {
                                  // TODO: Implementar edición
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ministry.description,
                            style: TextStyle(
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                          if (ministry.leaders.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Divider(
                              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.people,
                                  size: 20,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Líderes',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: ministry.leaders.map((leader) {
                                return Chip(
                                  avatar: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    child: Text(
                                      leader.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    '${leader.name} ${leader.lastname}',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  deleteIcon: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                  onDeleted: () async {
                                    await ministryProvider.removeLeader(
                                      ministryId: ministry.id,
                                      userId: leader.id,
                                    );
                                  },
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}