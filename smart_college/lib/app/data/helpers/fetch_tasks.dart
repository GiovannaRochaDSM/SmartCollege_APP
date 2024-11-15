import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class TaskHelper {
  static Future<List<TaskModel>> fetchAllTasks() async {
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

  static Future<List<TaskModel>> fetchTasksByDate({DateTime? selectedDate}) async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse(AppRoutes.task),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<TaskModel> tasks = jsonResponse.map((data) => TaskModel.fromMap(data)).toList();

      if (selectedDate != null) {
        tasks = tasks.where((task) {
          if (task.deadline != null) {
            bool isSameDayResult = isSameDay(task.deadline!, selectedDate);
            return isSameDayResult;
          }
          return false;
        }).toList();
      } else {
        DateTime now = DateTime.now();
        tasks = tasks.where((task) {
          if (task.deadline != null) {
            bool isBeforeOrSameDay = task.deadline!.isBefore(now) || isSameDay(task.deadline!, now);
            return isBeforeOrSameDay;
          }
          return false;
        }).toList();
      }

      return tasks;
    } else {
      throw Exception('Falha ao carregar as tarefas');
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static Future<List<TaskModel>> fetchTasksFilterSubjects({required String subjectId}) async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse(AppRoutes.task),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<TaskModel> tasks = jsonResponse.map((data) => TaskModel.fromMap(data)).toList();
      return tasks.where((task) => task.subjectId == subjectId).toList();
    } else {
      throw Exception('Falha ao carregar as tarefas');
    }
  }

  static Future<int> countPendingOrOngoingTasks({required String subjectId}) async {
    List<TaskModel> tasks = await fetchTasksFilterSubjects(subjectId: subjectId);
    int count = tasks.where((task) =>
        task.status == 'Pendente' || task.status == 'Em andamento').length;
    return count;
  }
}