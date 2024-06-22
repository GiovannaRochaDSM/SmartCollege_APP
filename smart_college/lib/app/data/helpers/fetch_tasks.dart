import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class TaskHelper {
  static Future<List<TaskModel>> fetchTasks() async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse(AppRoutes.task),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => TaskModel.fromMap(data)).toList();
    } else {
      throw Exception('Falha ao carregar as tarefas');
    }
  }
}