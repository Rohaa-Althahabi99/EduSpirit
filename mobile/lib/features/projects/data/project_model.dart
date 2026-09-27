class ProjectMemberModel {
  final String userId;
  final String fullName;
  final String role;
  ProjectMemberModel({required this.userId, required this.fullName, required this.role});

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) => ProjectMemberModel(
        userId: json['userId'] as String,
        fullName: json['fullName'] as String,
        role: json['roleInProject'] as String,
      );
}

class ProjectTaskModel {
  final String id;
  final String title;
  final bool isDone;
  ProjectTaskModel({required this.id, required this.title, required this.isDone});

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) =>
      ProjectTaskModel(id: json['id'] as String, title: json['title'] as String, isDone: json['isDone'] as bool);
}

class ProjectModel {
  final String id;
  final String title;
  final String? courseName;
  final String? description;
  final int progressPercent;
  final List<ProjectMemberModel> members;
  final List<ProjectTaskModel> tasks;

  ProjectModel({
    required this.id,
    required this.title,
    this.courseName,
    this.description,
    required this.progressPercent,
    required this.members,
    required this.tasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        title: json['title'] as String,
        courseName: json['courseName'] as String?,
        description: json['description'] as String?,
        progressPercent: json['progressPercent'] as int,
        members: (json['members'] as List).map((e) => ProjectMemberModel.fromJson(e)).toList(),
        tasks: (json['tasks'] as List).map((e) => ProjectTaskModel.fromJson(e)).toList(),
      );
}
