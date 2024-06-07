import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';
import 'package:smart_college/app/common/constants/app_routes.dart';

abstract class ISubjectRepository {
  Future<List<SubjectModel>> getSubjects();
  Future<bool> updateSubject(SubjectModel subject, String? token);
  Future<bool> addSubject(SubjectModel subject, String? token);
  Future<bool> deleteSubject(String subjectId, String? token);
}

class SubjectRepository implements ISubjectRepository {
  final IHttpClient client;

  SubjectRepository({required this.client});

  @override
  Future<List<SubjectModel>> getSubjects() async {
    final response = await client.get(url: AppRoutes.subjects);

    if (response.statusCode == 200) {
      final List<SubjectModel> subjects = [];
      final List<dynamic> body = jsonDecode(response.body);

      for (var item in body) {
        if (item is Map<String, dynamic> && item.containsKey('name')) {
          final SubjectModel subject = SubjectModel.fromMap(item);
          subjects.add(subject);
        }
      }
      return subjects;
    } else {
      throw Exception('Não foi possível carregar as matérias. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> updateSubject(SubjectModel subject, String? token) async {
    final response = await client.put(
      url: '${AppRoutes.subjects}${subject.id}',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },

      body: jsonEncode(subject.toMap()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao atualizar a matéria. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> addSubject(SubjectModel subject, String? token) async {
    final response = await client.post(
      url: AppRoutes.subjects,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(subject.toMap()),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Falha ao adicionar a matéria. Status code: ${response.statusCode}');
    }
  }

  @override
  Future<bool> deleteSubject(String subjectId, String? token) async {
    final response = await client.delete(
      url: '${AppRoutes.subjects}$subjectId',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Falha ao excluir a matéria. Status code: ${response.statusCode}');
    }
  }
}
