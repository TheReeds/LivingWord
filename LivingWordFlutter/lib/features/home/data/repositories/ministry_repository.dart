import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/ministry_model.dart';
import '../models/user_complete_model.dart';

class MinistryRepository {
  final Dio _client = ApiClient.instance;

  // Get all ministries
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

  // Get ministry by id
  Future<MinistryModel> getMinistryById(int id) async {
    try {
      final response = await _client.get('/ministries/$id');
      return MinistryModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching ministry: ${e.toString()}');
    }
  }

  // Create ministry
  Future<void> createMinistry({
    required String name,
    required String description,
  }) async {
    try {
      await _client.post(
        '/ministries/create',
        queryParameters: {
          'name': name,
          'description': description,
        },
      );
    } catch (e) {
      throw Exception('Error creating ministry: ${e.toString()}');
    }
  }

  // Edit ministry
  Future<void> editMinistry({
    required int id,
    required String newName,
    required String newDescription,
  }) async {
    try {
      await _client.put(
        '/ministries/edit/$id',
        queryParameters: {
          'newName': newName,
          'newDescription': newDescription,
        },
      );
    } catch (e) {
      throw Exception('Error editing ministry: ${e.toString()}');
    }
  }

  // Delete ministry
  Future<void> deleteMinistry(int id) async {
    try {
      await _client.delete('/ministries/delete/$id');
    } catch (e) {
      throw Exception('Error deleting ministry: ${e.toString()}');
    }
  }

  // Get ministry members
  Future<List<UserCompleteModel>> getMinistryMembers(int ministryId) async {
    try {
      final response = await _client.get('/ministries/$ministryId/members');
      return (response.data as List)
          .map((item) => UserCompleteModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching ministry members: ${e.toString()}');
    }
  }

  // Assign leader to ministry
  Future<void> assignLeader({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _client.post(
        '/ministries/assign-leader',
        queryParameters: {
          'ministryId': ministryId,
          'userId': userId,
        },
      );
    } catch (e) {
      throw Exception('Error assigning leader: ${e.toString()}');
    }
  }
  Future<void> submitSurveyResponses(Map<int, String> responses) async {
    try {
      await _client.post(
        '/ministries/survey/submit',
        data: {
          'responses': responses.map((key, value) => MapEntry(key.toString(), value)),
        },
      );
    } catch (e) {
      throw Exception('Error submitting survey: ${e.toString()}');
    }
  }

  // Remove leader from ministry
  Future<void> removeLeader({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _client.delete(
        '/ministries/remove-leader',
        queryParameters: {
          'ministryId': ministryId,
          'userId': userId,
        },
      );
    } catch (e) {
      throw Exception('Error removing leader: ${e.toString()}');
    }
  }

  // Affiliate user to ministry
  Future<void> affiliateUser({
    required int ministryId,
    required int userId,
  }) async {
    try {
      await _client.post(
        '/ministries/affiliate',
        queryParameters: {
          'ministryId': ministryId,
          'userId': userId,
        },
      );
    } catch (e) {
      throw Exception('Error affiliating user: ${e.toString()}');
    }
  }
}