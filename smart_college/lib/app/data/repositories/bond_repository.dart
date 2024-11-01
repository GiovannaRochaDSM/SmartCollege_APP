import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/bond_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class IBondRepository {
  Future<List<BondModel>> getBonds(String? token);
  Future<bool> requestBond(Map<String, dynamic> bond, String? token);
  Future<bool> acceptBond(String userId, String universityId, String? token);
  Future<bool> rejectBond(String userId, String? token);
}

class BondRepository implements IBondRepository {
  final IHttpClient client;

  BondRepository({required this.client});

  @override
  Future<List<BondModel>> getBonds(String? token) async {
    try {
      final response = await client.get(
        url: AppRoutes.bond,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> bondJson = json.decode(response.body);
        return bondJson.map((bond) => BondModel.fromMap(bond)).toList();
      } else {
        throw Exception('Erro ao buscar vínculos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição: $e');
    }
  }

  @override
  Future<bool> requestBond(Map<String, dynamic> bond, String? token) async {
    try {
      final response = await client.post(
        url: AppRoutes.bond,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bond),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Erro ao solicitar vínculo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição ao solicitar vínculo: $e');
    }
  }

  @override
  Future<bool> acceptBond(
      String userId, String universityId, String? token) async {
    try {
      final response = await client.put(
        url: '${AppRoutes.bond}/$userId/accept',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'universityId': universityId}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erro ao aceitar vínculo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição ao aceitar vínculo: $e');
    }
  }

  @override
  Future<bool> rejectBond(String userId, String? token) async {
    try {
      final response = await client.put(
        url: '${AppRoutes.bond}/$userId/reject',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Erro ao rejeitar vínculo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na requisição ao rejeitar vínculo: $e');
    }
  }
}
