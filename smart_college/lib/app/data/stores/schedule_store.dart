import 'package:flutter/material.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';
import 'package:smart_college/app/data/repositories/schedule_repository.dart';

class ScheduleStore {
  final IScheduleRepository repository;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<List<ScheduleModel>> state = ValueNotifier<List<ScheduleModel>>([]);
  final ValueNotifier<String> error = ValueNotifier<String>('');

  ScheduleStore({required this.repository});

  Future<void> getSchedules() async {
    isLoading.value = true;
    error.value = '';
    try {
      final result = await repository.getSchedules();
      state.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    isLoading.value = true;
    error.value = '';
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      await repository.deleteSchedule(scheduleId, token);
      state.value = state.value.where((schedule) => schedule.id != scheduleId).toList();
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}