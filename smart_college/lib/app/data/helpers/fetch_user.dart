import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class InfoHelper {
  static Future<UserModel> fetchUser() async {
    const storage = AppStrings.secureStorage;
    String? token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse(AppRoutes.me),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return UserModel.fromMap(jsonResponse);
    } else {
      throw Exception('Falha ao carregar seus dados');
    }
  }
}

