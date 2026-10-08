class LessonModel {
  final int id;
  final String title;
  final bool isCompleted;
  final String duration;

  const LessonModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.duration = '15 min',
  });

  LessonModel copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    String? duration,
  }) {
    return LessonModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'duration': duration,
    };
  }

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      duration: json['duration'] as String? ?? '15 min',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          isCompleted == other.isCompleted &&
          duration == other.duration;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ isCompleted.hashCode ^ duration.hashCode;
}
