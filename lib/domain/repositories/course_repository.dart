import '../../core/network/api_result.dart';
import '../../data/models/course_model.dart';

abstract class CourseRepository {
  /// Fetches courses from remote API when online, or falls back to local storage cache when offline
  Future<ApiResult<List<CourseModel>>> getCourses({
    bool forceRefresh = false,
    bool simulateFailure = false,
    bool simulateEmpty = false,
  });

  /// Updates course state (e.g. lesson progress) in local cache
  Future<void> updateCourse(CourseModel course);

  /// Checks if any cached course data is stored locally
  bool hasCachedData();

  /// Clears local course cache
  Future<void> clearCache();
}
