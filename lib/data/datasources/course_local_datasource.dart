import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../models/course_model.dart';

abstract class CourseLocalDataSource {
  Future<List<CourseModel>> getCachedCourses();
  Future<void> cacheCourses(List<CourseModel> courses);
  Future<void> updateCourse(CourseModel course);
  bool hasCachedCourses();
  Future<void> clearCache();
}

class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  final GetStorage _storage;

  CourseLocalDataSourceImpl({GetStorage? storage}) : _storage = storage ?? GetStorage();

  @override
  Future<List<CourseModel>> getCachedCourses() async {
    final rawData = _storage.read(StorageKeys.cachedCourses);
    if (rawData == null || rawData is! List) {
      return [];
    }

    return rawData
        .map((item) => CourseModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  @override
  Future<void> cacheCourses(List<CourseModel> courses) async {
    final jsonList = courses.map((course) => course.toJson()).toList();
    await _storage.write(StorageKeys.cachedCourses, jsonList);
    await _storage.write(StorageKeys.lastCacheTimestamp, DateTime.now().toIso8601String());
  }

  @override
  Future<void> updateCourse(CourseModel updatedCourse) async {
    final courses = await getCachedCourses();
    final index = courses.indexWhere((c) => c.id == updatedCourse.id);
    if (index != -1) {
      courses[index] = updatedCourse;
    } else {
      courses.add(updatedCourse);
    }
    await cacheCourses(courses);
  }

  @override
  bool hasCachedCourses() {
    final rawData = _storage.read(StorageKeys.cachedCourses);
    return rawData != null && rawData is List && rawData.isNotEmpty;
  }

  @override
  Future<void> clearCache() async {
    await _storage.remove(StorageKeys.cachedCourses);
    await _storage.remove(StorageKeys.lastCacheTimestamp);
  }
}
