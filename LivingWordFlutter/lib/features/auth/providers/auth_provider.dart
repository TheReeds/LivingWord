import 'package:flutter/material.dart';
import '../data/models/login_request.dart';
import '../data/models/signup_request.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';
import '../../../core/storage/secure_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  AuthProvider(this._repository);

  UserModel? get user => _user;
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
}