import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../models/paginated_prayers_response.dart';
import '../models/prayer_request_model.dart';

class PrayerRepository {
  final Dio _client = ApiClient.instance;

  Future<List<PrayerRequest>> getPrayersList() async {
    try {
      final response = await _client.get('/prayers/list');
      return (response.data as List)
          .map((item) => PrayerRequest.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Error fetching prayers: ${e.toString()}');
    }
  }

  Future<PaginatedPrayersResponse> getPrayersListOrdered({
    int page = 0,
    int size = 10,
    String sortBy = 'date',
    String sortDir = 'desc',
  }) async {
    try {
      final response = await _client.get(
        '/prayers/list-ordered',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDir': sortDir,
        },
      );
      return PaginatedPrayersResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching ordered prayers: ${e.toString()}');
    }
  }

  Future<PrayerRequest> getPrayerById(int id) async {
    try {
      final response = await _client.get('/prayers/$id');
      return PrayerRequest.fromJson(response.data);
    } catch (e) {
      throw Exception('Error fetching prayer: ${e.toString()}');
    }
  }

  Future<List<String>> getPrayerSupporters(int id) async {
    try {
      final response = await _client.get('/prayers/$id/supporters');
      return (response.data as List).map((e) => e.toString()).toList();
    } catch (e) {
      throw Exception('Error fetching supporters: ${e.toString()}');
    }
  }

  Future<void> createPrayer(String description) async {
    try {
      await _client.post('/prayers/create', data: description);
    } catch (e) {
      throw Exception('Error creating prayer: ${e.toString()}');
    }
  }

  Future<void> supportPrayer(int id) async {
    try {
      await _client.post('/prayers/$id/support');
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 500) {
        final errorMessage = e.response?.data['details'] ?? 'Error supporting prayer';
        throw Exception(errorMessage);
      }
      throw Exception('Error supporting prayer: ${e.toString()}');
    }
  }
  Future<void> deletePrayer(int id) async {
    try {
      await _client.delete('/prayers/$id/delete');
    } catch (e) {
      throw Exception('Error deleting prayer: ${e.toString()}');
    }
  }
}