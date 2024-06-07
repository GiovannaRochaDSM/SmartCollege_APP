import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';
import 'package:smart_college/app/common/constants/app_strings.dart';

class SubjectHelper {
  static Future<List<SubjectModel>> fetchSubjects() async {
    String? token = await AppStrings.secureStorage.read(key: 'token');
    final response = await http.get(
      Uri.parse(AppRoutes.subjects),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => SubjectModel.fromMap(data)).toList();
    } else {
      throw Exception('Falha ao carregar as matérias');
    }
  }
}
