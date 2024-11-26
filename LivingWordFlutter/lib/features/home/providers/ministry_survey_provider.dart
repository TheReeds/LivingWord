import 'package:flutter/foundation.dart';

import '../data/models/ministry_survey_model.dart';
import '../data/repositories/ministry_survey_repository.dart';

class MinistrySurveyProvider extends ChangeNotifier {
  final MinistrySurveyRepository _repository;
  List<MinistrySurveyResponse> _responses = [];
  bool _isLoading = false;
  String? _error;

  MinistrySurveyProvider(this._repository);

  List<MinistrySurveyResponse> get responses => _responses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadResponses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _responses = await _repository.getSurveyResponses();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitResponses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitSurveyResponses(_responses);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void updateResponse(int ministryId, String response) {
    final index = _responses.indexWhere((r) => r.ministryId == ministryId);
    if (index != -1) {
      _responses[index] = MinistrySurveyResponse(
        ministryId: ministryId,
        ministryName: _responses[index].ministryName,
        response: response,
      );
      notifyListeners();
    }
  }
}