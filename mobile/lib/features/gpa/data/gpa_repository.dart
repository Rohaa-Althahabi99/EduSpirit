import '../../../core/network/api_client.dart';

class SemesterGpa {
  final String semester;
  final double gpa;
  final int creditHours;
  SemesterGpa({required this.semester, required this.gpa, required this.creditHours});

  factory SemesterGpa.fromJson(Map<String, dynamic> json) => SemesterGpa(
        semester: json['semester'] as String,
        gpa: (json['gpa'] as num).toDouble(),
        creditHours: json['creditHours'] as int,
      );
}

class GpaResult {
  final double semesterGpa;
  final double overallGpa;
  final int totalCreditHours;
  final List<SemesterGpa> bySemester;

  GpaResult({required this.semesterGpa, required this.overallGpa, required this.totalCreditHours, required this.bySemester});

  factory GpaResult.fromJson(Map<String, dynamic> json) => GpaResult(
        semesterGpa: (json['semesterGpa'] as num).toDouble(),
        overallGpa: (json['overallGpa'] as num).toDouble(),
        totalCreditHours: json['totalCreditHours'] as int,
        bySemester: (json['bySemester'] as List).map((e) => SemesterGpa.fromJson(e)).toList(),
      );
}

class GpaRepository {
  final ApiClient _apiClient;
  GpaRepository(this._apiClient);

  Future<GpaResult> get() async {
    final response = await _apiClient.dio.get('/gpa');
    return GpaResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addGrade({
    required String courseId,
    required String semester,
    required String letterGrade,
    required double gradePoints,
    required int creditHours,
  }) async {
    await _apiClient.dio.post('/gpa/grades', data: {
      'courseId': courseId,
      'semester': semester,
      'letterGrade': letterGrade,
      'gradePoints': gradePoints,
      'creditHours': creditHours,
    });
  }
}
