import 'package:flutter/foundation.dart';
import '../data/models/ministry_model.dart';
import '../data/models/user_complete_model.dart';
import '../data/repositories/ministry_repository.dart';

class MinistryProvider extends ChangeNotifier {
  final MinistryRepository _repository;
  List<MinistryModel> _ministries = [];
  MinistryModel? _selectedMinistry;
  List<UserCompleteModel> _ministryMembers = [];
  bool _isLoading = false;
  String? _error;

  MinistryProvider(this._repository);

  // Getters
  List<MinistryModel> get ministries => _ministries;
  MinistryModel? get selectedMinistry => _selectedMinistry;
  List<UserCompleteModel> get ministryMembers => _ministryMembers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load all ministries
  Future<void> loadMinistries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ministries = await _repository.getMinistries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load ministry by id
  Future<void> loadMinistryById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedMinistry = await _repository.getMinistryById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create ministry
  Future<void> createMinistry({
    required String name,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createMinistry(
        name: name,
        description: description,
      );
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Edit ministry
  Future<void> editMinistry({
    required int id,
    required String newName,
    required String newDescription,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.editMinistry(
        id: id,
        newName: newName,
        newDescription: newDescription,
      );
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete ministry
  Future<void> deleteMinistry(int id) async {
    try {
      await _repository.deleteMinistry(id);
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Load ministry members
  Future<void> loadMinistryMembers(int ministryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ministryMembers = await _repository.getMinistryMembers(ministryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Assign leader
  Future<void> assignLeader({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _repository.assignLeader(
        ministryId: ministryId,
        userId: userId,
      );
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Remove leader
  Future<void> removeLeader({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _repository.removeLeader(
        ministryId: ministryId,
        userId: userId,
      );
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Affiliate user
  Future<void> affiliateUser({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _repository.affiliateUser(
        ministryId: ministryId,
        userId: userId,
      );
      await loadMinistries(); // Refresh the list
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  Future<void> submitSurveyResponses(Map<int, String> responses) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitSurveyResponses(responses);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}