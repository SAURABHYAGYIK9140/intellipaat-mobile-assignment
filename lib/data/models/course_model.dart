import 'lesson_model.dart';

class CourseModel {
  final int id;
  final String title;
  final String instructor;
  final int progress; // percentage 0 - 100
  final int lessons; // total number of lessons
  final List<LessonModel> lessonList;

  const CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.lessons,
    this.lessonList = const [],
  });

  /// Factory constructor to generate standard syllabus lessons if none provided
  static List<LessonModel> generateDefaultLessons(int courseId, String courseTitle, int currentProgress) {
    List<String> lessonNames;
    switch (courseId) {
      case 1:
        lessonNames = [
          'Introduction',
          'Variables & Data Types',
          'Functions & Scope',
          'OOP & Classes',
          'Modules & Packages',
          'File Handling & Exceptions',
        ];
        break;
      case 2:
        lessonNames = [
          'Foundations of LLMs',
          'Prompt Engineering Principles',
          'Embeddings & Vector Databases',
          'RAG Architecture & Retrieval',
          'Fine-tuning & Evaluation',
        ];
        break;
      case 3:
        lessonNames = [
          'Web Architecture & Protocols',
          'Frontend with Reactive UI',
          'RESTful API & Database Design',
          'Authentication & State Management',
          'Production Deployment & CI/CD',
        ];
        break;
      default:
        lessonNames = [
          'Introduction',
          'Fundamentals & Core Concepts',
          'Intermediate Architecture',
          'Advanced Implementation',
          'Capstone Project',
        ];
    }

    // Determine how many should start completed to match progress approximation
    final completedTarget = ((currentProgress / 100) * lessonNames.length).round();

    return List.generate(lessonNames.length, (index) {
      return LessonModel(
        id: index + 1,
        title: lessonNames[index],
        isCompleted: index < completedTarget,
        duration: '${15 + (index * 5)} min',
      );
    });
  }

  /// Calculates progress dynamically based on completed lessons
  static int calculateProgressPercentage(List<LessonModel> lessons) {
    if (lessons.isEmpty) return 0;
    final completedCount = lessons.where((l) => l.isCompleted).length;
    final calculated = ((completedCount / lessons.length) * 100).round();
    return calculated.clamp(0, 100);
  }

  CourseModel copyWith({
    int? id,
    String? title,
    String? instructor,
    int? progress,
    int? lessons,
    List<LessonModel>? lessonList,
  }) {
    return CourseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      progress: progress ?? this.progress,
      lessons: lessons ?? this.lessons,
      lessonList: lessonList ?? this.lessonList,
    );
  }

  /// Returns a new CourseModel with updated lesson state and recalculated progress
  CourseModel withToggledLesson(int lessonId) {
    final updatedList = lessonList.map((lesson) {
      if (lesson.id == lessonId) {
        return lesson.copyWith(isCompleted: !lesson.isCompleted);
      }
      return lesson;
    }).toList();

    final newProgress = calculateProgressPercentage(updatedList);
    return copyWith(
      lessonList: updatedList,
      progress: newProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'progress': progress,
      'lessons': lessons,
      'lessonList': lessonList.map((l) => l.toJson()).toList(),
    };
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final title = json['title'] as String? ?? '';
    final instructor = json['instructor'] as String? ?? '';
    final progress = (json['progress'] as num?)?.toInt() ?? 0;
    final lessons = (json['lessons'] as num?)?.toInt() ?? 0;

    List<LessonModel> lessonsParsed = [];
    if (json['lessonList'] != null && json['lessonList'] is List) {
      lessonsParsed = (json['lessonList'] as List)
          .map((item) => LessonModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } else {
      lessonsParsed = generateDefaultLessons(id, title, progress);
    }

    return CourseModel(
      id: id,
      title: title,
      instructor: instructor,
      progress: progress,
      lessons: lessons,
      lessonList: lessonsParsed,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          instructor == other.instructor &&
          progress == other.progress &&
          lessons == other.lessons;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ instructor.hashCode ^ progress.hashCode ^ lessons.hashCode;
}
