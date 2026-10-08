import '../../core/network/api_result.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/course_local_datasource.dart';
import '../datasources/course_remote_datasource.dart';
import '../models/course_model.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _remoteDataSource;
  final CourseLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  CourseRepositoryImpl({
    required CourseRemoteDataSource remoteDataSource,
    required CourseLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo;

  @override
  Future<ApiResult<List<CourseModel>>> getCourses({
    bool forceRefresh = false,
    bool simulateFailure = false,
    bool simulateEmpty = false,
  }) async {
    // 1. If currently offline, directly serve from local persistent cache
    if (!_networkInfo.isConnected) {
      final cachedCourses = await _localDataSource.getCachedCourses();
      if (cachedCourses.isNotEmpty) {
        return Success(cachedCourses);
      }
      return const Failure(
        message: 'You are offline and no cached courses are available. Please connect once to sync.',
        statusCode: 503,
      );
    }

    // 2. Online: Try remote API fetch
    try {
      final remoteCourses = await _remoteDataSource.fetchCourses(
        simulateFailure: simulateFailure,
        simulateEmpty: simulateEmpty,
      );

      // On successful fetch, sync/cache into local storage
      if (remoteCourses.isNotEmpty) {
        // If we already had cached progress for these courses, preserve the user's lesson progress!
        final existingCache = await _localDataSource.getCachedCourses();
        final mergedCourses = _mergeWithCachedProgress(remoteCourses, existingCache);
        await _localDataSource.cacheCourses(mergedCourses);
        return Success(mergedCourses);
      } else {
        return const Success([]);
      }
    } catch (e) {
      // 3. Graceful Offline/Error Fallback: If remote API fails, fall back to local cache if available
      final cachedCourses = await _localDataSource.getCachedCourses();
      if (cachedCourses.isNotEmpty) {
        return Success(cachedCourses);
      }
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        originalException: e,
      );
    }
  }

  /// Preserves user's local lesson completion progress if new courses are fetched
  List<CourseModel> _mergeWithCachedProgress(
    List<CourseModel> fresh,
    List<CourseModel> cached,
  ) {
    if (cached.isEmpty) return fresh;

    final cachedMap = {for (var c in cached) c.id: c};
    return fresh.map((freshCourse) {
      final cachedCourse = cachedMap[freshCourse.id];
      if (cachedCourse != null && cachedCourse.lessonList.isNotEmpty) {
        // Preserve user's local lesson completion
        return freshCourse.copyWith(
          lessonList: cachedCourse.lessonList,
          progress: CourseModel.calculateProgressPercentage(cachedCourse.lessonList),
        );
      }
      return freshCourse;
    }).toList();
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    await _localDataSource.updateCourse(course);
  }

  @override
  bool hasCachedData() {
    return _localDataSource.hasCachedCourses();
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }
}
