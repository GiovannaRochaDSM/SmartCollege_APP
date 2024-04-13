import 'dart:convert';
import 'package:smart_college/app/data/http/http_client.dart';
import 'package:smart_college/app/data/models/subject_model.dart';

const String subjectsBaseUrl = 'https://smartcollege-api.onrender.com/subjects/';

abstract class ISubjectRepository {
  Future<List<SubjectModel>> getSubjects();
  Future<bool> updateSubject(SubjectModel subject);
  Future<bool> addSubject(SubjectModel subject);
  Future<bool> deleteSubject(String subjectId);
}

class SubjectRepository implements ISubjectRepository {
  final IHttpClient client;

  SubjectRepository({required this.client});

  @override
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final response = await client.get(url: subjectsBaseUrl);

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
        throw Exception(
            'Não foi possível carregar as matérias. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao carregar as matérias: $e');
    }
  }

  @override
  Future<bool> updateSubject(SubjectModel subject) async {
    try {
      final response = await client.put(
       url: '$subjectsBaseUrl${subject.id}',
        body: jsonEncode(subject.toMap()),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Falha ao atualizar a matéria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar a matéria: $e');
    }
  }

  @override
  Future<bool> addSubject(SubjectModel subject) async {
    try {
      final response = await client.post(
        url: subjectsBaseUrl,
        body: jsonEncode(subject.toMap()),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
            'Falha ao adicionar a matéria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao adicionar a matéria: $e');
    }
  }

  @override
  Future<bool> deleteSubject(String subjectId) async {
    try {
      final response = await client.delete(
        url: '$subjectsBaseUrl$subjectId',
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Falha ao excluir a matéria. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao excluir a matéria: $e');
    }
  }
}
