class UniversityModel {
  final String id;
  final String name;
  final String state;
  final String city;
  final List<String> degreeCourse;

  UniversityModel({
    required this.id,
    required this.name,
    required this.state,
    required this.city,
    required this.degreeCourse,
  });

  factory UniversityModel.fromMap(Map<String, dynamic> map) {
    return UniversityModel(
      id: map['_id'],
      name: map['name'],
      state: map['state'],
      city: map['city'],
      degreeCourse: List<String>.from(map['degreeCourse']),
    );
  }
}