import 'package:flutter/foundation.dart';

import '../data/models/paginated_prayers_response.dart';
import '../data/models/prayer_request_model.dart';
import '../data/repositories/prayer_repository.dart';

class PrayerProvider extends ChangeNotifier {
  final PrayerRepository _repository;
  List<PrayerRequest> _prayers = [];
  PaginatedPrayersResponse? _paginatedPrayers;
  bool _isLoading = false;
  String? _error;
  List<String> _supporters = [];
  bool _isSupportersLoading = false;
  int _currentPage = 0;
  String _currentSortDir = 'desc';

  PrayerProvider(this._repository) {
    loadPaginatedPrayers();
  }

  List<String> get supporters => _supporters;
  bool get isSupportersLoading => _isSupportersLoading;
  List<PrayerRequest> get prayers => _prayers;
  PaginatedPrayersResponse? get paginatedPrayers => _paginatedPrayers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSupporters(int prayerId) async {
    _isSupportersLoading = true;
    notifyListeners();

    try {
      _supporters = await _repository.getPrayerSupporters(prayerId);
    } catch (e) {
      _error = e.toString();
    }

    _isSupportersLoading = false;
    notifyListeners();
  }

  Future<void> loadPaginatedPrayers({
    int? page,
    int size = 10,
    String sortBy = 'date',
    String? sortDir,
  }) async {
    _isLoading = true;
    _error = null;

    if (page != null) _currentPage = page;
    if (sortDir != null) _currentSortDir = sortDir;

    notifyListeners();

    try {
      _paginatedPrayers = await _repository.getPrayersListOrdered(
        page: _currentPage,
        size: size,
        sortBy: sortBy,
        sortDir: _currentSortDir,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPrayer(String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createPrayer(description);
      // Recargar la página actual después de crear
      await loadPaginatedPrayers(page: 0); // Volver a la primera página
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow; // Permitir que el error sea manejado por el UI
    }
  }

  Future<void> supportPrayer(int id) async {
    try {
      await _repository.supportPrayer(id);
      // Actualizar la página actual sin cambiar de página
      await loadPaginatedPrayers();
    } catch (e) {
      rethrow; // Permitir que el error sea manejado por el UI
    }
  }

  Future<void> deletePrayer(int id) async {
    try {
      await _repository.deletePrayer(id);
      // Recargar la página actual después de borrar
      await loadPaginatedPrayers();
    } catch (e) {
      rethrow; // Permitir que el error sea manejado por el UI
    }
  }
}