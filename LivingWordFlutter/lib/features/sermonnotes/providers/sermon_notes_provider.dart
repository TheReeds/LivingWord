import 'package:flutter/material.dart';
import '../data/repositories/sermon_notes_repository.dart';
import '../data/models/sermon_note_model.dart';

class SermonNotesProvider extends ChangeNotifier {
  final SermonNotesRepository _repository = SermonNotesRepository();

  List<SermonNoteModel>? _sermonNotes;
  bool _isLoading = false;
  String? _error;
  String _sortOrder = 'desc';
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLastPage = false;
  static const int _pageSize = 10;

  // Getters
  List<SermonNoteModel>? get sermonNotes => _sermonNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get sortOrder => _sortOrder;
  bool get isLastPage => _isLastPage;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  Future<void> loadSermonNotes({bool refresh = false}) async {
    // Si estamos refrescando o es la primera carga
    if (refresh) {
      _currentPage = 0;
      _sermonNotes = null;
      _error = null;
      _isLastPage = false;
    }

    // Si ya estamos cargando o hemos llegado al final, no hacemos nada
    if (_isLoading || (!refresh && _isLastPage)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getSermonNotes(
        page: _currentPage,
        size: _pageSize,
        sort: _sortOrder,
      );

      final List<SermonNoteModel> newNotes = result['content'];

      if (_currentPage == 0) {
        _sermonNotes = newNotes;
      } else {
        _sermonNotes = [...?_sermonNotes, ...newNotes];
      }

      _totalPages = result['totalPages'];
      _isLastPage = result['last'];
      _currentPage++;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleSortOrder() async {
    if (_isLoading) return;

    _sortOrder = _sortOrder == 'desc' ? 'asc' : 'desc';
    await loadSermonNotes(refresh: true);
  }

  Future<void> refreshSermonNotes() async {
    await loadSermonNotes(refresh: true);
  }

  Future<void> createSermonNote(String title, String sermonUrl) async {
    try {
      _error = null;
      final newNote = await _repository.createSermonNote({
        'title': title,
        'sermonurl': sermonUrl,
      });

      // Actualizar la lista local si es necesario
      if (_sortOrder == 'desc' && _sermonNotes != null) {
        _sermonNotes!.insert(0, newNote);
        notifyListeners();
      } else {
        // Si el orden es ascendente o no tenemos notas, recargamos todo
        await loadSermonNotes(refresh: true);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateSermonNote(int id, String title, String sermonUrl) async {
    try {
      _error = null;
      final updatedNote = await _repository.updateSermonNote(id, {
        'title': title,
        'sermonurl': sermonUrl,
      });

      // Actualizar la nota en la lista local
      if (_sermonNotes != null) {
        final index = _sermonNotes!.indexWhere((note) => note.id == id);
        if (index != -1) {
          _sermonNotes![index] = updatedNote;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteSermonNote(int id) async {
    try {
      _error = null;
      await _repository.deleteSermonNote(id);

      // Eliminar la nota de la lista local
      if (_sermonNotes != null) {
        _sermonNotes!.removeWhere((note) => note.id == id);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para limpiar los datos cuando el usuario cierra sesión
  void clear() {
    _sermonNotes = null;
    _error = null;
    _isLoading = false;
    _currentPage = 0;
    _totalPages = 0;
    _isLastPage = false;
    notifyListeners();
  }
}