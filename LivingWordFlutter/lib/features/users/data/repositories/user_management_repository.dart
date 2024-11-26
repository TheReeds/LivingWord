import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/permission_model.dart';
import '../models/role_model.dart';
import '../models/user_model.dart';

class UserManagementRepository {
  final Dio _client = ApiClient.instance;


  Future<List<User>> getUsers() async {
    try {
      final response = await _client.get('/users');
      return (response.data as List)
          .map((user) => User.fromJson(user))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener usuarios: $e');
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _client.get('/users/$id');
      return User.fromJson(response.data);
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _client.delete('/users/$userId');
    } catch (e) {
      throw Exception('Error al eliminar usuario: $e');
    }
  }

  Future<void> updateUser(int userId, User user) async {
    try {
      await _client.put('/users/$userId', data: user.toJson());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  Future<void> assignRole(int userId, int roleId) async {
    try {
      await _client.post('/users/assign-role', data: {
        'userId': userId,
        'roleId': roleId,
      });
    } catch (e) {
      throw Exception('Error al asignar rol: $e');
    }
  }

  Future<void> removeRole(int userId, int roleId) async {
    try {
      await _client.post('/users/remove-role', data: {
        'userId': userId,
        'roleId': roleId,
      });
    } catch (e) {
      throw Exception('Error al remover rol: $e');
    }
  }

  Future<List<Role>> getRoles() async {
    try {
      final response = await _client.get('/roles');
      return (response.data as List)
          .map((role) => Role.fromJson(role))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener roles: $e');
    }
  }

  Future<void> createRole(String name, int level, List<String> permissions) async {
    try {
      await _client.post('/roles/create', data: {
        'name': name,
        'level': level,
        'permissions': permissions,
      });
    } catch (e) {
      throw Exception('Error al crear rol: $e');
    }
  }

  Future<void> deleteRole(int roleId) async {
    try {
      await _client.delete('/roles/$roleId');
    } catch (e) {
      throw Exception('Error al eliminar rol: $e');
    }
  }

  Future<void> updateRolePermissions(int roleId, List<String> permissions) async {
    try {
      await _client.put('/roles/$roleId/permissions', data: permissions);
    } catch (e) {
      throw Exception('Error al actualizar permisos del rol: $e');
    }
  }

  Future<List<Permission>> getPermissions() async {
    try {
      final response = await _client.get('/permissions');
      return (response.data as List)
          .map((permission) => Permission.fromJson(permission))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener permisos: $e');
    }
  }
}