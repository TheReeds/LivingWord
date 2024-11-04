import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../data/models/newsletter_model.dart';

class NewslettersState {
  final List<NewsletterModel> newsletters;
  final NewsletterModel? featuredNewsletter;
  final bool isLoading;
  final String? error;
  final int totalPages;
  final int currentPage;

  const NewslettersState({
    this.newsletters = const [],
    this.featuredNewsletter,
    this.isLoading = false,
    this.error,
    this.totalPages = 0,
    this.currentPage = 0,
  });

  NewslettersState copyWith({
    List<NewsletterModel>? newsletters,
    NewsletterModel? featuredNewsletter,
    bool? isLoading,
    String? error,
    int? totalPages,
    int? currentPage,
  }) {
    return NewslettersState(
      newsletters: newsletters ?? this.newsletters,
      featuredNewsletter: featuredNewsletter ?? this.featuredNewsletter,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class NewslettersProvider with ChangeNotifier {
  NewslettersState _state = const NewslettersState();
  NewslettersState get state => _state;

  Future<void> loadNewsletters({int page = 0, int size = 10}) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      final response = await ApiClient.instance.get(
        ApiConstants.newslettersEndpoint,
        queryParameters: {
          'page': page,
          'size': size,
          'sort': 'desc',
        },
      );

      final data = response.data;
      final List<NewsletterModel> allNewsletters = (data['content'] as List)
          .map((item) => NewsletterModel.fromJson(item))
          .toList();

      final newsletters = allNewsletters.isNotEmpty
          ? allNewsletters.skip(1).toList()
          : <NewsletterModel>[];

      _state = _state.copyWith(
        newsletters: page > 0
            ? [..._state.newsletters, ...newsletters]
            : newsletters,
        featuredNewsletter: allNewsletters.isNotEmpty ? allNewsletters.first : null,
        totalPages: data['totalPages'] ?? 0,
        currentPage: data['number'] ?? 0,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  Future<void> createNewsletter({
    required String title,
    required String newsletterUrl,
  }) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      await ApiClient.instance.post(
        ApiConstants.newslettersEndpoint,
        data: {
          'title': title,
          'newsletterUrl': newsletterUrl,
        },
      );

      await loadNewsletters();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      throw e;
    }
  }

  Future<void> updateNewsletter({
    required int id,
    required String title,
    required String newsletterUrl,
  }) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      await ApiClient.instance.put(
        ApiConstants.newsletterByIdEndpoint(id),
        data: {
          'title': title,
          'newsletterUrl': newsletterUrl,
        },
      );

      await loadNewsletters();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      throw e;
    }
  }

  Future<void> deleteNewsletter(int id) async {
    try {
      _state = _state.copyWith(isLoading: true, error: null);
      notifyListeners();

      await ApiClient.instance.delete(
        ApiConstants.newsletterByIdEndpoint(id),
      );

      await loadNewsletters();
    } catch (e) {
      _state = _state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      notifyListeners();
      throw e;
    }
  }
}