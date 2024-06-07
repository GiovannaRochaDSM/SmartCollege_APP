class UserModel {
  final String id;
  final String name;
  final String studentRecord;
  final String nickname;
  final String? photo;
  final String email;
  final String password;
  final String? passwordResetToken;
  final String? passwordResetExpires;
  final DateTime createAt;
  final bool bond;
  final bool isCoord;

  UserModel({
    required this.id,
    required this.name,
    required this.studentRecord,
    required this.nickname,
    this.photo,
    required this.email,
    required this.password,
    this.passwordResetToken,
    this.passwordResetExpires,
    DateTime? createAt,
    required this.bond,
    required this.isCoord,
  }) : createAt = createAt ?? DateTime.now();


  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      studentRecord: map['studentRecord'] ?? '',
      nickname: map['nickname'] ?? '',
      photo: map['photo'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      passwordResetToken: map['passwordResetToken'] ?? '',
      passwordResetExpires: map['passwordResetExpires'] ?? '',
      createAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      bond: map['bond'] ?? false,
      isCoord: map['isCoord'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'studentRecord': studentRecord,
      'nickname': nickname,
      'photo': photo,
      'email': email,
      'password': password,
      'passwordResetToken': passwordResetToken,
      'passwordResetExpires': passwordResetExpires,
      'createdAt': createAt.toIso8601String(),
      'bond': bond,
      'isCoord': isCoord,
    };
  }

   UserModel updatePhoto(String? newPhoto) {
    return UserModel(
      id: id,
      name: name,
      studentRecord: studentRecord,
      nickname: nickname,
      photo: newPhoto,
      email: email,
      password: password,
      passwordResetToken: passwordResetToken,
      passwordResetExpires: passwordResetExpires,
      createAt: createAt,
      bond: bond,
      isCoord: isCoord,
    );
  }
}
