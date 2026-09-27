class ExamChecklistItemModel {
  final String id;
  final String content;
  final bool isDone;
  ExamChecklistItemModel({required this.id, required this.content, required this.isDone});

  factory ExamChecklistItemModel.fromJson(Map<String, dynamic> json) => ExamChecklistItemModel(
        id: json['id'] as String,
        content: json['content'] as String,
        isDone: json['isDone'] as bool,
      );
}

class ExamModel {
  final String id;
  final String courseName;
  final String examType;
  final DateTime examDate;
  final int daysRemaining;
  final String? hallLocation;
  final String? importantTopics;
  final int difficulty;
  final int priority;
  final List<ExamChecklistItemModel> checklist;

  ExamModel({
    required this.id,
    required this.courseName,
    required this.examType,
    required this.examDate,
    required this.daysRemaining,
    this.hallLocation,
    this.importantTopics,
    required this.difficulty,
    required this.priority,
    required this.checklist,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) => ExamModel(
        id: json['id'] as String,
        courseName: json['courseName'] as String,
        examType: json['examType'] as String,
        examDate: DateTime.parse(json['examDate'] as String),
        daysRemaining: json['daysRemaining'] as int,
        hallLocation: json['hallLocation'] as String?,
        importantTopics: json['importantTopics'] as String?,
        difficulty: json['difficulty'] as int,
        priority: json['priority'] as int,
        checklist: (json['checklist'] as List? ?? [])
            .map((e) => ExamChecklistItemModel.fromJson(e))
            .toList(),
      );
}
