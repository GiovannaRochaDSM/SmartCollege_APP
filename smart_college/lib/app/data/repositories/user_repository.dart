import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class IUserRepository {
  Future<bool> updateUser(UserModel user, String? token);
  Future<bool> deleteUser(String userId, String? token);
  Future<bool> addUser(UserModel user, String? token);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String email, String password);
}

class UserRepository implements IUserRepository {
  final IHttpClient client;

  UserRepository({required this.client});

  @override
  Future<bool> addUser(UserModel user, String? token) async {
    final response = await client.post(
      url: AppRoutes.register,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao se cadastrar. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateUser(UserModel user, String? token) async {
    final response = await client.put(
      url: AppRoutes.me += user.id,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao atualizar seus dados. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteUser(String userId, String? token) async {
    final response = await client.delete(
      url: AppRoutes.me += userId,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir sua conta. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await client.post(
        url: AppRoutes.forgotPassword,
        body: jsonEncode({'email': email}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao solicitar redefinição de senha.');
      }
    } catch (e) {
      throw Exception('Erro ao solicitar redefinição de senha: $e');
    }
  }

  @override
  Future<void> resetPassword(
      String token, String email, String password) async {
    try {
      final response = await client.post(
        url: AppRoutes.resetPassword += token,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao redefinir a senha.');
      }
    } catch (e) {
      throw Exception('Erro ao redefinir senha: $e');
    }
  }
}
