class SubjectModel {
  final String id;
  final String name;
  final String acronym;
  final List<int>? grades;
  final int? abscence;

  SubjectModel({
    required this.id,
    required this.name,
    required this.acronym,
    this.grades,
    this.abscence,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'acronym': acronym,
      'grades': grades?.map((grade) => grade.toString()).toList(),
      'abscence': abscence,
    };
  }
}
