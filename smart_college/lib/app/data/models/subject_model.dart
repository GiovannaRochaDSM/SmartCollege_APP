import 'dart:io';
import 'dart:convert';

class SubjectModel {
  final String id;
  late String name;
  final String acronym;
  final List<int>? grades;
  final int? abscence;
  late final String? notes;

  SubjectModel({
    required this.id,
    required this.name,
    required this.acronym,
    this.grades,
    this.abscence,
    this.notes,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> map) {
    return SubjectModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      acronym: map['acronym'] ?? '',
      grades: (map['grades'] as List<dynamic>?)
          ?.map((grade) => grade is int ? grade : int.parse(grade.toString()))
          .toList(),
      abscence: map['abscence'] is int
          ? map['abscence']
          : int.parse(map['abscence'].toString()),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'acronym': acronym,
      'grades': grades?.map((grade) => grade.toString()).toList(),
      'abscence': abscence,
      'notes': notes,
    };
  }

  Future<void> exportToTextFile() async {
    String content = 'ID: $id\n';
    content += 'Nome: $name\n';
    content += 'Sigla: $acronym\n';
    content += 'Notas: ${grades?.join(", ") ?? "Nenhuma nota"}\n';
    content += 'Faltas: $abscence\n';
    content += 'Anotações: ${notes ?? "Nenhuma anotação"}\n';
    final file = File('materia_$id.txt');
    await file.writeAsString(content);
  }

  Future<void> exportToJsonFile() async {
    Map<String, dynamic> data = this.toMap();
    String jsonContent = jsonEncode(data);
    final file = File('materia_$id.json');
    await file.writeAsString(jsonContent);
  }
}
