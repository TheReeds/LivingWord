import 'package:flutter/cupertino.dart';
import 'package:living_word/features/home/data/models/ministry_model.dart';
import 'package:living_word/features/home/data/repositories/ministry_survey_repository.dart';

import '../data/models/ministry_response_detail.dart';
import '../data/models/ministry_statistics.dart';

class MinistryStatisticsProvider extends ChangeNotifier {
  final MinistrySurveyRepository _repository;
  List<MinistryModel> _ministries = [];
  MinistryStatistics? _currentStatistics;
  List<MinistryResponseDetail> _responses = [];
  bool _isLoading = false;
  String? _error;

  MinistryStatisticsProvider(this._repository);

  List<MinistryModel> get ministries => _ministries;
  MinistryStatistics? get currentStatistics => _currentStatistics;
  List<MinistryResponseDetail> get responses => _responses;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  Future<void> loadStatistics(int ministryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentStatistics = await _repository.getMinistryStatistics(ministryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllResponses(int ministryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _responses = await _repository.getAllResponses(ministryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadResponsesByType(int ministryId, String responseType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _responses = await _repository.getResponsesByType(ministryId, responseType);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}