import 'package:dio/dio.dart';
import 'package:living_word/features/home/data/models/ministry_model.dart';
import '../../../../core/api/api_client.dart';
import '../models/ministry_response_detail.dart';
import '../models/ministry_statistics.dart';
import '../models/ministry_survey_model.dart';

class MinistrySurveyRepository {
  final Dio _client = ApiClient.instance;

  Future<List<MinistrySurveyResponse>> getSurveyResponses() async {
    try {
      final response = await _client.get('/ministries/surveys/with-responses');
      return (response.data as List)
          .map((item) => MinistrySurveyResponse.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching survey responses: ${e.toString()}');
    }
  }

  Future<void> submitSurveyResponses(List<MinistrySurveyResponse> responses) async {
    try {
      final List<Map<String, dynamic>> data = responses
          .where((response) => response.response != null)
          .map((response) => response.toJson())
          .toList();

      await _client.post('/ministries/surveys/responses', data: data);
    } catch (e) {
      throw Exception('Error submitting survey responses: ${e.toString()}');
    }
  }
  Future<List<MinistryModel>> getMinistries() async {
    try {
      final response = await _client.get('/ministries/list');
      return (response.data as List)
          .map((item) => MinistryModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching ministries: ${e.toString()}');
    }
  }

  Future<MinistryStatistics> getMinistryStatistics(int ministryId) async {
    try {
      final response = await _client.get('/ministries/surveys/$ministryId/statistics');
      return MinistryStatistics.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching ministry statistics: ${e.toString()}');
    }
  }

  Future<List<MinistryResponseDetail>> getAllResponses(int ministryId) async {
    try {
      final response = await _client.get('/ministries/surveys/$ministryId/responses');
      return (response.data as List)
          .map((item) => MinistryResponseDetail.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching ministry responses: ${e.toString()}');
    }
  }

  Future<List<MinistryResponseDetail>> getResponsesByType(
      int ministryId,
      String responseType,
      ) async {
    try {
      final response = await _client.get(
        '/ministries/surveys/$ministryId/responses/$responseType',
      );
      return (response.data as List)
          .map((item) => MinistryResponseDetail.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching responses by type: ${e.toString()}');
    }
  }
}