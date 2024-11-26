import 'package:flutter/material.dart';
import 'package:living_word/features/home/data/models/user_complete_model.dart';
import '../data/models/login_request.dart';
import '../data/models/signup_request.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _user;
  List<UserCompleteModel> _users = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  AuthProvider(this._repository);

  UserModel? get user => _user;
  List<UserCompleteModel> get users => _users;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }

  Future login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = LoginRequest(email: email, password: password);
      _user = await _repository.login(request);
      await SecureStorage.saveToken(_user!.token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    _user = null;
    notifyListeners();
  }
  Future<bool> signup(SignupRequest request) async {
    _isLoading = true;
    _error = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.signup(request);
      _isLoading = false;
      _successMessage = 'Registro exitoso. Se ha enviado un correo de confirmación a su dirección de email.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _repository.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception:', '').trim();
      _isLoading = false;
      notifyListeners();
    }
  }
  List<UserCompleteModel> filterUsers(String query) {
    return _users.where((user) =>
    user.fullName.toLowerCase().contains(query.toLowerCase()) ||
        (user.ministry?.toLowerCase() ?? '')
            .contains(query.toLowerCase())).toList();
  }
  Future<void> refreshUserDetails() async {
    if (_user != null) {
      try {
        final updatedUser = await _repository.getUserById(_user!.id);
        _user = updatedUser;
        notifyListeners();
      } catch (e) {
        print('Error refreshing user details: $e');
      }
    }
  }
}