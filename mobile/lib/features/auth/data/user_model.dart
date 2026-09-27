class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? university;
  final String? major;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.university,
    this.major,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        university: json['university'] as String?,
        major: json['major'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}
