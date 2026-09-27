class NoteModel {
  final String id;
  final String title;
  final String? contentRichText;
  final String noteType;
  final String? courseName;
  final String? folderName;
  final String? tags;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    this.contentRichText,
    required this.noteType,
    this.courseName,
    this.folderName,
    this.tags,
    required this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        title: json['title'] as String,
        contentRichText: json['contentRichText'] as String?,
        noteType: json['noteType'] as String,
        courseName: json['courseName'] as String?,
        folderName: json['folderName'] as String?,
        tags: json['tags'] as String?,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
