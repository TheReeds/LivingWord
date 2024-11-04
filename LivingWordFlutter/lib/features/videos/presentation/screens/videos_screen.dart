import 'package:flutter/material.dart';
import 'package:living_word/features/videos/presentation/screens/video_form.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/models/video_model.dart';
import 'package:provider/provider.dart';
import '../../providers/videos_provider.dart';
import '../widgets/video_card.dart';
import 'create_video_screen.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({Key? key}) : super(key: key);

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VideosProvider>().loadVideos(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      final videosProvider = context.read<VideosProvider>();
      if (!videosProvider.isLoading && !videosProvider.hasReachedEnd) {
        videosProvider.loadMoreVideos();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, VideosProvider>(
      builder: (context, authProvider, videosProvider, child) {
        final user = authProvider.user;
        final hasWritePermission = user?.permissions.contains('PERM_VIDEO_WRITE') ?? false;
        final hasEditPermission = user?.permissions.contains('PERM_VIDEO_EDIT') ?? false;
        final hasDeletePermission = user?.permissions.contains('PERM_VIDEO_DELETE') ?? false;
        final isAdmin = user?.permissions.contains('PERM_ADMIN_ACCESS') ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Videos',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  videosProvider.toggleSortOrder();
                  videosProvider.loadVideos(isRefresh: true);
                },
                icon: Icon(
                  videosProvider.sortOrder == 'desc' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: Colors.black,
                ),
                label: Text(
                  videosProvider.sortOrder == 'desc' ? 'Most Recent' : 'Oldest First',
                  style: const TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => videosProvider.loadVideos(isRefresh: true),
            child: Builder(
              builder: (context) {
                if (!videosProvider.isInitialized && videosProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (videosProvider.videos.isEmpty && !videosProvider.isLoading) {
                  return _buildEmptyState(hasWritePermission || isAdmin);
                }

                return _buildVideosList(
                  videosProvider,
                  hasEditPermission || isAdmin,
                  hasDeletePermission || isAdmin,
                );
              },
            ),
          ),
          floatingActionButton: hasWritePermission || isAdmin
              ? FloatingActionButton.extended(
            onPressed: () => _navigateToCreateVideo(context),
            label: const Text('New Video'),
            icon: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          )
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(bool canAdd) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No videos available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (canAdd) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToCreateVideo(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Video'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideosList(VideosProvider videosProvider, bool canEdit, bool canDelete) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: videosProvider.videos.length + (videosProvider.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == videosProvider.videos.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final video = videosProvider.videos[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: VideoCard(
            video: video,
            canEdit: canEdit,
            canDelete: canDelete,
            onEdit: () => _navigateToEditVideo(context, video),
            onDelete: () => _showDeleteConfirmation(context, video),
            onTap: () => _launchYouTube(video.youtubeUrl, context),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateVideo(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateVideoScreen(),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      context.read<VideosProvider>().loadVideos(isRefresh: true);
    }
  }

  Future<void> _navigateToEditVideo(BuildContext context, VideoModel video) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditVideoScreen(video: video),
      ),
    );

    if (result == true) {
      if (!mounted) return;
      context.read<VideosProvider>().loadVideos(isRefresh: true);
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, VideoModel video) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Are you sure you want to delete this video?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<VideosProvider>().deleteVideo(video.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video deleted successfully')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting video: $e')),
        );
      }
    }
  }

  Future<void> _launchYouTube(String url, BuildContext context) async {
    try {
      final Uri youtubeUrl = Uri.parse(url);
      if (await canLaunchUrl(youtubeUrl)) {
        await launchUrl(youtubeUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Unable to open video';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error opening video on YouTube')),
      );
    }
  }
}
