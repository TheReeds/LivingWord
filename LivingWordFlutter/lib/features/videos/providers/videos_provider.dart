import 'package:flutter/cupertino.dart';

import '../data/models/video_model.dart';
import '../data/repositories/videos_repository.dart';

class VideosProvider with ChangeNotifier {
  final VideoRepository _repository;
  List<VideoModel> _videos = [];
  bool _isLoading = false;
  bool _hasReachedEnd = false;
  bool _isInitialized = false;
  int _currentPage = 0;
  final int _pageSize = 10;
  String _sortOrder = 'desc';

  VideosProvider(this._repository);

  List<VideoModel> get videos => _videos;
  bool get isLoading => _isLoading;
  bool get hasReachedEnd => _hasReachedEnd;
  String get sortOrder => _sortOrder;
  bool get isInitialized => _isInitialized;

  Future<void> loadVideos({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 0;
      _hasReachedEnd = false;
      _videos = [];
    }

    if (_isLoading || (_hasReachedEnd && !isRefresh)) return;

    try {
      _isLoading = true;
      notifyListeners();

      final newVideos = await _repository.getVideos(
        page: _currentPage,
        size: _pageSize,
        sortOrder: _sortOrder,
      );

      if (newVideos.isEmpty) {
        _hasReachedEnd = true;
      } else {
        if (isRefresh) {
          _videos = newVideos;
        } else {
          _videos = [..._videos, ...newVideos];
        }
        _currentPage++;
      }

      _isInitialized = true;  // Marcar como inicializado después de la primera carga

    } catch (e) {
      print('Error loading videos: $e');
      rethrow;  // Propagar el error para manejarlo en la UI
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVideo(String title, String youtubeUrl) async {
    try {
      _isLoading = true;
      notifyListeners();

      final video = VideoModel(
        title: title,
        youtubeUrl: youtubeUrl,
      );

      final newVideo = await _repository.addVideo(video);

      // Insertar al inicio de la lista si estamos ordenando por desc
      // o al final si estamos ordenando por asc
      if (_sortOrder == 'desc') {
        _videos.insert(0, newVideo);
      } else {
        _videos.add(newVideo);
      }

    } catch (e) {
      print('Error adding video: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVideo(int id, String title, String youtubeUrl) async {
    try {
      final video = VideoModel(
        id: id,
        title: title,
        youtubeUrl: youtubeUrl,
      );

      final updatedVideo = await _repository.updateVideo(id, video);

      // Actualizar el video en la lista local manteniendo su posición
      final index = _videos.indexWhere((v) => v.id == id);
      if (index != -1) {
        _videos[index] = updatedVideo;
        notifyListeners();
      }

    } catch (e) {
      print('Error updating video: $e');
      rethrow;
    }
  }

  Future<void> deleteVideo(int id) async {
    try {
      await _repository.deleteVideo(id);
      _videos.removeWhere((video) => video.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting video: $e');
      rethrow;
    }
  }

  void toggleSortOrder() {
    _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc';
    notifyListeners();
  }

  void loadMoreVideos() {
    if (!_isLoading && !_hasReachedEnd) {
      loadVideos();
    }
  }
  void reset() {
    _videos = [];
    _isLoading = false;
    _hasReachedEnd = false;
    _isInitialized = false;
    _currentPage = 0;
    notifyListeners();
  }

}