class NotificationModel {
  final String id;
  final String userId;
  final String? taskId;
  final String title;
  final String body;
  final DateTime scheduledTime;

  NotificationModel({
    required this.id,
    required this.userId,
    this.taskId,
    required this.title,
    required this.body,
    required this.scheduledTime,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['_id'] ?? '',
      userId: map['userId'] ?? '',
      taskId: map['taskId'], 
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      scheduledTime: DateTime.parse(map['scheduledTime']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'taskId': taskId,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
    };
  }
}
