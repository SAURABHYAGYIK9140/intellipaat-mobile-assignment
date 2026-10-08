import '../models/course_model.dart';

abstract class CourseRemoteDataSource {
  Future<List<CourseModel>> fetchCourses({bool simulateFailure = false, bool simulateEmpty = false});
}

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  // Raw JSON representation directly matching the assignment specification
  static const List<Map<String, dynamic>> _mockCourseJson = [
    {
      "id": 1,
      "title": "Python Programming",
      "instructor": "John Smith",
      "progress": 65,
      "lessons": 20,
    },
    {
      "id": 2,
      "title": "Generative AI",
      "instructor": "Sarah Williams",
      "progress": 40,
      "lessons": 16,
    },
    {
      "id": 3,
      "title": "Full Stack Development",
      "instructor": "David Brown",
      "progress": 25,
      "lessons": 28,
    },
  ];

  @override
  Future<List<CourseModel>> fetchCourses({
    bool simulateFailure = false,
    bool simulateEmpty = false,
  }) async {
    // Simulate realistic mobile network latency
    await Future.delayed(const Duration(milliseconds: 650));

    if (simulateFailure) {
      throw Exception('500 Internal Server Error: Failed to fetch courses from remote server.');
    }

    if (simulateEmpty) {
      return [];
    }

    return _mockCourseJson.map((json) => CourseModel.fromJson(json)).toList();
  }
}
