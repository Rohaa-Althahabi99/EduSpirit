import '../../timetable/data/timetable_entry_model.dart';

class ExamCountdownModel {
  final String courseName;
  final String examType;
  final DateTime examDate;
  final int daysRemaining;
  final String? hallLocation;

  ExamCountdownModel({
    required this.courseName,
    required this.examType,
    required this.examDate,
    required this.daysRemaining,
    this.hallLocation,
  });

  factory ExamCountdownModel.fromJson(Map<String, dynamic> json) => ExamCountdownModel(
        courseName: json['courseName'] as String,
        examType: json['examType'] as String,
        examDate: DateTime.parse(json['examDate'] as String),
        daysRemaining: json['daysRemaining'] as int,
        hallLocation: json['hallLocation'] as String?,
      );
}

class DashboardModel {
  final String greetingName;
  final List<TimetableEntryModel> todaySchedule;
  final ExamCountdownModel? nextExam;
  final double attendancePercentage;
  final int pendingTasksCount;

  DashboardModel({
    required this.greetingName,
    required this.todaySchedule,
    required this.nextExam,
    required this.attendancePercentage,
    required this.pendingTasksCount,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
        greetingName: json['greetingName'] as String,
        todaySchedule: (json['todaySchedule'] as List)
            .map((e) => TimetableEntryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextExam: json['nextExam'] != null
            ? ExamCountdownModel.fromJson(json['nextExam'] as Map<String, dynamic>)
            : null,
        attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
        pendingTasksCount: json['pendingTasksCount'] as int,
      );
}
