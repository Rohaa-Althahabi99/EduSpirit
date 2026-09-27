import 'package:flutter/material.dart';

enum TimetableEntryType { lecture, online, lab, workshop, seminar, custom }

class TimetableEntryModel {
  final String id;
  final String title;
  final TimetableEntryType type;
  final String? courseName;
  final String? location;
  final String? onlineLink;
  final int? dayOfWeek; // 1=Sunday..7=Saturday
  final String startTime; // "HH:mm"
  final String endTime;
  final Color color;

  TimetableEntryModel({
    required this.id,
    required this.title,
    required this.type,
    this.courseName,
    this.location,
    this.onlineLink,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.color,
  });

  factory TimetableEntryModel.fromJson(Map<String, dynamic> json) => TimetableEntryModel(
        id: json['id'] as String,
        title: json['title'] as String,
        type: TimetableEntryType.values.firstWhere(
          (e) => e.name == (json['entryType'] as String).toLowerCase(),
          orElse: () => TimetableEntryType.custom,
        ),
        courseName: json['courseName'] as String?,
        location: json['location'] as String?,
        onlineLink: json['onlineLink'] as String?,
        dayOfWeek: json['dayOfWeek'] as int?,
        startTime: (json['startTime'] as String).substring(0, 5),
        endTime: (json['endTime'] as String).substring(0, 5),
        color: _colorFromHex(json['colorHex'] as String? ?? '#2F6FED'),
      );

  static Color _colorFromHex(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }
}
