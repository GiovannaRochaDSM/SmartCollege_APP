import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/pages/onboarding_page.dart';
import 'package:smart_college/app/data/models/user_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class AuthService {
  static Future<bool> register(String email, String password) async {
    var url = Uri.parse(AppRoutes.register);
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      await AppStrings.secureStorage.write(key: 'token', value: jsonDecode(response.body)['token']);
      return true;
    } else {
      return false;
    }
  }
  
  static Future<bool> login(String email, String password) async {
    var url = Uri.parse(AppRoutes.authenticate);
    var response = await http.post(
      url,
      body: {
        'email': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      await AppStrings.secureStorage.write(key: 'token', value: jsonDecode(response.body)['token']);
      return true;
    } else {
      return false;
    }
  }

  static Future<void> logout(BuildContext context) async {
    await AppStrings.secureStorage.delete(key: 'token');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // TO DO: Direcionar para Onboarding
        builder: (context) => const OnboardingPage(),
      ),
    );
  }

  static Future<String?> getToken() async {
    return await AppStrings.secureStorage.read(key: 'token');
  }

  static Future<void> setToken(String token) async {
    await AppStrings.secureStorage.write(key: 'token', value: token);
  }

  static Future<void> saveUserData(UserModel user) async {
  await AppStrings.secureStorage.write(key: 'userData', value: jsonEncode(user.toMap()));
}
}

