import 'package:flutter/material.dart';
import '../../data/models/video_model.dart';
import 'video_card.dart';

class VideoSearchPage extends StatefulWidget {
  final List<VideoModel> videos;
  final bool canEdit;
  final bool canDelete;
  final Function(VideoModel)? onEdit;
  final Function(VideoModel)? onDelete;
  final Function(VideoModel) onVideoSelect;

  const VideoSearchPage({
    Key? key,
    required this.videos,
    this.canEdit = false,
    this.canDelete = false,
    this.onEdit,
    this.onDelete,
    required this.onVideoSelect,
  }) : super(key: key);

  @override
  State<VideoSearchPage> createState() => _VideoSearchPageState();
}

class _VideoSearchPageState extends State<VideoSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<VideoModel> _filteredVideos = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredVideos = widget.videos;
  }

  void _filterVideos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredVideos = widget.videos.where((video) {
        return video.title.toLowerCase().contains(_searchQuery) ||
            (video.uploadedByUsername?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterVideos,
            decoration: InputDecoration(
              hintText: 'Search videos',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterVideos('');
                },
              )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[300],
            height: 1,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filteredVideos.length,
        itemBuilder: (context, index) {
          final video = _filteredVideos[index];
          return VideoCard(
            video: video,
            canEdit: widget.canEdit,
            canDelete: widget.canDelete,
            onEdit: widget.onEdit != null
                ? () => widget.onEdit!(video)
                : null,
            onDelete: widget.onDelete != null
                ? () => widget.onDelete!(video)
                : null,
            onTap: () => widget.onVideoSelect(video),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to VideoForm
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}