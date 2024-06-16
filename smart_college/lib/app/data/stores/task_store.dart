import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/task_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/repositories/task_repository.dart';

class TaskStore {
  final ITaskRepository repository;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<TaskModel>> state = ValueNotifier<List<TaskModel>>([]);
  final ValueNotifier<String> error = ValueNotifier<String>('');

  TaskStore({required this.repository});

  Future<void> getTasks() async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await repository.getTasks();
      state.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(String taskId) async {
    isLoading.value = true;
    error.value = '';
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      await repository.deleteTask(taskId, token);
      state.value = state.value.where((task) => task.id != taskId).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}