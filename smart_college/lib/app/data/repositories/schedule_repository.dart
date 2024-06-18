import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class IScheduleRepository {
  Future<List<ScheduleModel>> getSchedules();
  Future<bool> updateSchedule(ScheduleModel schedule, String? token);
  Future<bool> addSchedule(ScheduleModel schedule, String? token);
  Future<bool> deleteSchedule(String scheduleId, String? token);
}

class ScheduleRepository implements IScheduleRepository {
  final IHttpClient client;

  ScheduleRepository({required this.client});

  @override
  Future<List<ScheduleModel>> getSchedules() async {
    final response = await client.get(url: AppRoutes.schedules);

    if (response.statusCode == 200) {
      final List<ScheduleModel> schedules = [];
      final List<dynamic> body = jsonDecode(response.body);

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('id')) {
          final ScheduleModel schedule = ScheduleModel.fromMap(item);
          schedules.add(schedule);
        }
      }
      return schedules;
    } else {
      throw Exception('Não foi possível carregar os horários. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateSchedule(ScheduleModel schedules, String? token) async {
    final response = await client.put(
      url: '${AppRoutes.schedules}${schedules.id}',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedules.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao atualizar a tarefa. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> addSchedule(ScheduleModel schedules, String? token) async {
    final response = await client.post(
      url: AppRoutes.schedules,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(schedules.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao adicionar a tarefa. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteSchedule(String scheduleId, String? token) async {
    final response = await client.delete(
      url: '${AppRoutes.schedules}$scheduleId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir o horário. Status code: ${response.statusCode}');
    }
  }
}