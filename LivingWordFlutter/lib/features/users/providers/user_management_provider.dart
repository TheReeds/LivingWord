import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:living_word/features/auth/data/models/user_model.dart';

import '../data/models/permission_model.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_management_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserManagementRepository _repository;
  List<User> _users = [];
  List<Role> _roles = [];
  List<Permission> _permissions = [];
  bool _isLoading = false;
  String? _error;

  UserManagementProvider(this._repository);

  bool get isLoading => _isLoading;
  List<User> get users => _users;
  List<Role> get roles => _roles;
  List<Permission> get permissions => _permissions;
  String? get error => _error;


  Future<void> fetchUsers() async {
    try {
      _setLoading(true);
      _users = await _repository.getUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      _setLoading(true);
      await _repository.deleteUser(userId);
      await fetchUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateUser(int userId, User user) async {
    try {
      _setLoading(true);
      await _repository.updateUser(userId, user);
      await fetchUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> assignRole(int userId, int roleId) async {
    try {
      _setLoading(true);
      await _repository.assignRole(userId, roleId);
      await fetchUsers();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchRoles() async {
    try {
      _setLoading(true);
      _roles = await _repository.getRoles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createRole(String name, int level, List<String> permissions) async {
    try {
      _setLoading(true);
      await _repository.createRole(name, level, permissions);
      await fetchRoles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> deleteRole(int roleId) async {
    try {
      _setLoading(true);
      await _repository.deleteRole(roleId);
      await fetchRoles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> updateRolePermissions(int roleId, List<String> permissions) async {
    try {
      _setLoading(true);
      await _repository.updateRolePermissions(roleId, permissions);
      await fetchRoles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchPermissions() async {
    try {
      _setLoading(true);
      _permissions = await _repository.getPermissions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}