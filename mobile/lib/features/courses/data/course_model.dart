import 'package:flutter/material.dart';

class CourseModel {
  final String id;
  final String name;
  final String? code;
  final String? professorName;
  final Color color;
  final int creditHours;
  final String? semester;

  CourseModel({
    required this.id,
    required this.name,
    this.code,
    this.professorName,
    required this.color,
    required this.creditHours,
    this.semester,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String?,
        professorName: json['professorName'] as String?,
        color: _colorFromHex(json['colorHex'] as String? ?? '#2F6FED'),
        creditHours: json['creditHours'] as int,
        semester: json['semester'] as String?,
      );

  static Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
