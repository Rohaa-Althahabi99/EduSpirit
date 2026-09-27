import '../../../core/network/api_client.dart';

class CourseAttendanceStats {
  final String courseId;
  final String courseName;
  final int totalSessions;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final double attendancePercentage;

  CourseAttendanceStats({
    required this.courseId,
    required this.courseName,
    required this.totalSessions,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.attendancePercentage,
  });

  factory CourseAttendanceStats.fromJson(Map<String, dynamic> json) => CourseAttendanceStats(
        courseId: json['courseId'] as String,
        courseName: json['courseName'] as String,
        totalSessions: json['totalSessions'] as int,
        presentCount: json['presentCount'] as int,
        absentCount: json['absentCount'] as int,
        lateCount: json['lateCount'] as int,
        attendancePercentage: (json['attendancePercentage'] as num).toDouble(),
      );
}

class AttendanceRepository {
  final ApiClient _apiClient;
  AttendanceRepository(this._apiClient);

  Future<List<CourseAttendanceStats>> getStats() async {
    final response = await _apiClient.dio.get('/attendance/stats');
    return (response.data as List).map((e) => CourseAttendanceStats.fromJson(e)).toList();
  }

  Future<void> mark({required String courseId, required DateTime sessionDate, required String status}) async {
    final dateOnly = '${sessionDate.year}-${sessionDate.month.toString().padLeft(2, '0')}-${sessionDate.day.toString().padLeft(2, '0')}';
    await _apiClient.dio.post('/attendance', data: {
      'courseId': courseId,
      'sessionDate': dateOnly,
      'status': status,
    });
  }
}
