import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks();
  Future<bool> updateTask(TaskModel task, String? token);
  Future<bool> addTask(TaskModel task, String? token);
  Future<bool> deleteTask(String taskId, String? token);
}

class TaskRepository implements ITaskRepository {
  final IHttpClient client;

  TaskRepository({required this.client});

  @override
  Future<List<TaskModel>> getTasks() async {
    final response = await client.get(url: AppRoutes.task);

    if (response.statusCode == 200) {
      final List<TaskModel> tasks = [];
      final List<dynamic> body = jsonDecode(response.body);

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          final TaskModel task = TaskModel.fromMap(item);
          tasks.add(task);
        }
      }
      return tasks;
    } else {
      throw Exception('Não foi possível carregar as tarefas. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateTask(TaskModel task, String? token) async {
    final response = await client.put(
      url: '${AppRoutes.task}${task.id}',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao atualizar a tarefa. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> addTask(TaskModel task, String? token) async {
    final response = await client.post(
      url: AppRoutes.task,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(task.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao adicionar a tarefa. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteTask(String taskId, String? token) async {
    final response = await client.delete(
      url: '${AppRoutes.task}$taskId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir a tarefa. Status code: ${response.statusCode}');
    }
  }
}