import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/models/schedule_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class ScheduleHelper {
  static Future<List<ScheduleModel>> fetchSchedules() async {
    try {
      String? token = await AppStrings.secureStorage.read(key: 'token');
      final response = await http.get(
        Uri.parse(AppRoutes.schedules),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => ScheduleModel.fromMap(data)).toList();
      } else {
        throw Exception('Falha ao carregar os horários, tente novamente.');
      }
    } catch (e) {
      throw Exception('Falha interna ao carregar os horários.');
    }
  }
}