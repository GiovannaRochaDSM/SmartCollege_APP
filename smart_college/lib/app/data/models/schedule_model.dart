class ScheduleModel {
  final String id;
  final String dayWeek;
  final String? room;
  final String? time;
  final String subjectId;
  final String? subjectName;

  ScheduleModel({
    required this.id,
    required this.dayWeek,
    this.room,
    this.time,
    required this.subjectId,
    this.subjectName,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['_id'] ?? '',
      dayWeek: map['dayWeek'] ?? '',
      room: map['room'],
      time: map['time'],
      subjectId: map['subject']?['_id'] ?? '',
      subjectName: map['subject']?['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'dayWeek': dayWeek,
      'room': room,
      'time': time,
      'subject': {
        '_id': subjectId,
        'name': subjectName,
      },
    };
  }
}