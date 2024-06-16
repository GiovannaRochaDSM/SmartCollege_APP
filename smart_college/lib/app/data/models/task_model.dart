class TaskModel {
  final String id;
  final String name;
  final String? description;
  final String priority;
  final DateTime? deadline;
  final String status;
  final String subjectId; 
  final String? subjectName; // Adicionado o subjectName
  final String? category;

  TaskModel({
    required this.id,
    required this.name,
    this.description,
    required this.priority,
    this.deadline,
    required this.status,
    required this.subjectId,
    this.subjectName, // Adicionado o subjectName
    this.category,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      priority: map['priority'] ?? 'Média',
      deadline: map['deadline'] != null ? DateTime.parse(map['deadline']) : null,
      status: map['status'] ?? 'Pendente',
      subjectId: map['subject']?['_id'] ?? '',
      subjectName: map['subject']?['name'] ?? '', // Atribuindo o subjectName
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'deadline': deadline?.toIso8601String(),
      'status': status,
      'subject': subjectId,
      'category': category,
    };
  }
}