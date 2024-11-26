import 'package:flutter/material.dart';
import 'dart:io';

import '../data/models/user_details_model.dart';
import '../data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;
  UserDetailsModel? _userDetails;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._repository);

  UserDetailsModel? get userDetails => _userDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserDetails(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userDetails = await _repository.getUserDetails(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserDetails(UserDetailsModel details) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateUserDetails(details.id, details);
      _userDetails = details;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileImage(File image) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.updateProfileImage(image);
      await loadUserDetails(_userDetails!.id);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> deleteProfileImage() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteProfileImage();
      await loadUserDetails(_userDetails!.id);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}