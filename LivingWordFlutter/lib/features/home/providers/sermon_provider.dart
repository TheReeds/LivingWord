import 'package:flutter/material.dart';

import '../data/models/event/sermon_model.dart';
import '../data/repositories/sermon_repository.dart';

class SermonProvider extends ChangeNotifier {
  final SermonRepository _repository;
  List<SermonModel> _sermons = [];
  SermonModel? _activeSermon;
  bool _isLoading = false;
  String? _error;

  SermonProvider(this._repository);

  List<SermonModel> get sermons => _sermons;
  SermonModel? get activeSermon => _activeSermon;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSermons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _sermons = await _repository.getSermons();
      _activeSermon = _sermons.firstWhere((sermon) => sermon.active, orElse: () => _sermons.last);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSermon({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String videoLink,
    required String summary,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final sermon = await _repository.createSermon(
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        videoLink: videoLink,
        summary: summary,
      );
      _sermons.add(sermon);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSermon({
    required int id,
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required String videoLink,
    required String summary,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedSermon = await _repository.updateSermon(
        id: id,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        videoLink: videoLink,
        summary: summary,
      );

      final index = _sermons.indexWhere((sermon) => sermon.id == id);
      if (index != -1) {
        _sermons[index] = updatedSermon;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startSermon(int id) async {
    try {
      final startedSermon = await _repository.startSermon(id);
      final index = _sermons.indexWhere((sermon) => sermon.id == id);
      if (index != -1) {
        _sermons[index] = startedSermon;
        _activeSermon = startedSermon;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> endSermon(int id) async {
    try {
      final endedSermon = await _repository.endSermon(id);
      final index = _sermons.indexWhere((sermon) => sermon.id == id);
      if (index != -1) {
        _sermons[index] = endedSermon;
        if (_activeSermon?.id == id) {
          _activeSermon = null;
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSermon(int id) async {
    try {
      await _repository.deleteSermon(id);
      _sermons.removeWhere((sermon) => sermon.id == id);
      if (_activeSermon?.id == id) {
        _activeSermon = null;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}