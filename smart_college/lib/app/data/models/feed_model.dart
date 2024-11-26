class FeedModel {
  final String id;
  final String? title;
  final String? publication;
  final DateTime dateTime;
  final String? image;
  int likes;
  final List<String> likedBy;
  final String userId;
  String userName;
  final String? userEmail;
  final String? userPhoto;
  final String universityId;
  final String universityName;

  FeedModel({
    required this.id,
    this.title,
    this.publication,
    DateTime? dateTime,
    this.image,
    this.likes = 0,
    this.likedBy = const [],
    required this.userId,
    required this.userName,
    this.userEmail,
    this.userPhoto,
    required this.universityId,
    required this.universityName,
  }) : dateTime = dateTime ?? DateTime.now();

  factory FeedModel.fromMap(Map<String, dynamic> map) {
    return FeedModel(
      id: map['_id'] ?? '',
      title: map['title'] ?? '',
      publication: map['publication'] ?? '',
      dateTime: map['dateTime'] != null ? DateTime.parse(map['dateTime']) : DateTime.now(),
      image: map['image'] ?? '',
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      userId: map['user']?['_id'] ?? '',
      userName: map['user']?['nickname'] ?? '',
      userEmail: map['user']?['email'],
      userPhoto: map['user']?['photo'],
      universityId: map['university']?['_id'] ?? '',
      universityName: map['university']?['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'publication': publication,
      'dateTime': dateTime.toIso8601String(),
      'image': image,
      'likes': likes,
      'likedBy': likedBy,
      'user': {
        '_id': userId,
        'nickname': userName,
        'email': userEmail,
        'photo': userPhoto,
      },
      'university': {
        '_id': universityId,
        'name': universityName,
      },
    };
  }

  FeedModel updateImage(String? newImage) {
    return FeedModel(
      id: id,
      title: title,
      publication: publication,
      dateTime: dateTime,
      image: newImage,
      likes: likes,
      likedBy: likedBy,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhoto: userPhoto,
      universityId: universityId,
      universityName: universityName
      );
  }
}