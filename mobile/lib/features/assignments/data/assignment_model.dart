class AssignmentModel {
  final String id;
  final String title;
  final String? courseName;
  final String assignmentType;
  final String? description;
  final DateTime dueDate;
  final int priority;
  final int progressPercent;
  final String status;

  AssignmentModel({
    required this.id,
    required this.title,
    this.courseName,
    required this.assignmentType,
    this.description,
    required this.dueDate,
    required this.priority,
    required this.progressPercent,
    required this.status,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) => AssignmentModel(
        id: json['id'] as String,
        title: json['title'] as String,
        courseName: json['courseName'] as String?,
        assignmentType: json['assignmentType'] as String,
        description: json['description'] as String?,
        dueDate: DateTime.parse(json['dueDate'] as String),
        priority: json['priority'] as int,
        progressPercent: json['progressPercent'] as int,
        status: json['status'] as String,
      );

  bool get isDone => status == 'submitted' || status == 'graded';
}
