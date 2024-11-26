import 'dart:io';

import 'package:flutter/material.dart';
import '../data/models/event/event_model.dart';
import '../data/repositories/events_repository.dart';

class EventsProvider extends ChangeNotifier {
  final EventsRepository _repository;
  List<EventModel> _events = [];
  bool _isLoading = false;
  String? _error;
  bool _isMinistryView = false;
  bool _hasMoreEvents = true;

  // Filtering state
  String? _selectedMinistry;
  DateTimeRange? _dateRange;

  EventsProvider(this._repository);

  // Getters
  List<EventModel> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isMinistryView => _isMinistryView;
  bool get hasMoreEvents => _hasMoreEvents;

  Future<void> loadEvents({
    required int page,
    bool ministryOnly = false,
    bool refresh = false,
  }) async {
    if (_isLoading) return;

    // Siempre limpiar eventos cuando cambiamos entre All/Ministry view
    if (_isMinistryView != ministryOnly || refresh) {
      _events = [];
      _hasMoreEvents = true;
      page = 1; // Reset page when switching views
    }

    if (!_hasMoreEvents && !refresh) return;

    _isLoading = true;
    _error = null;
    _isMinistryView = ministryOnly; // Update view type before notifying
    notifyListeners();

    try {
      final newEvents = ministryOnly
          ? await _repository.getMinistryEvents(
        page: page,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      )
          : await _repository.getAllEvents(
        page: page,
        ministry: _selectedMinistry,
        startDate: _dateRange?.start,
        endDate: _dateRange?.end,
      );

      _events = refresh ? newEvents : [..._events, ...newEvents];
      _hasMoreEvents = newEvents.length == 10; // Assuming 10 is the page limit
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents(page: 1, ministryOnly: _isMinistryView, refresh: true);
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    File? imageFile,
  }) async {
    try {
      await _repository.createEvent(
        title: title,
        description: description,
        location: location,
        eventDate: eventDate,
        imageFile: imageFile,
      );
      await refreshEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent({
    required int id,
    required String title,
    required String description,
    required String location,
    required DateTime eventDate,
    File? imageFile,
  }) async {
    try {
      await _repository.updateEvent(
        id: id,
        title: title,
        description: description,
        location: location,
        eventDate: eventDate,
        imageFile: imageFile,
      );
      await refreshEvents();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(int id) async {
    try {
      await _repository.deleteEvent(id);
      await refreshEvents();
    } catch (e) {
      rethrow;
    }
  }

  void applyFilters({
    String? ministry,
    DateTimeRange? dateRange,
  }) {
    _selectedMinistry = ministry;
    _dateRange = dateRange;
    refreshEvents();
  }

  void clearFilters() {
    _selectedMinistry = null;
    _dateRange = null;
    refreshEvents();
  }
}
