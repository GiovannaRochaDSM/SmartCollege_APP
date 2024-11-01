class BondModel {
  final String id;
  final String emailCoord;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String universityId;
  final String? universityName;
  final String? status;

  BondModel({
    required this.id,
    required this.emailCoord,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.universityId,
    this.universityName,
    this.status,
  });

  factory BondModel.fromMap(Map<String, dynamic> map) {
    return BondModel(
      id: map['_id'],
      emailCoord: map['emailCoord'],
      userId: map['user']?['_id'] ?? '',
      userName: map['user']?['name'] ?? '',
      userEmail: map['user']?['email'],
      universityId: map['university']?['_id'] ?? '',
      universityName: map['university']?['name'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emailCoord': emailCoord,
      'user': userId,
      'university': universityId,
    };
  }
}
