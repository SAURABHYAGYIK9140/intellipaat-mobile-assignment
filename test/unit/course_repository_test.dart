import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:learning_dashboard/core/network/api_result.dart';
import 'package:learning_dashboard/core/network/network_info.dart';
import 'package:learning_dashboard/data/datasources/course_local_datasource.dart';
import 'package:learning_dashboard/data/datasources/course_remote_datasource.dart';
import 'package:learning_dashboard/data/models/course_model.dart';
import 'package:learning_dashboard/data/models/lesson_model.dart';
import 'package:learning_dashboard/data/repositories/course_repository_impl.dart';

// Test doubles / fakes for isolated, deterministic unit testing
class FakeCourseRemoteDataSource implements CourseRemoteDataSource {
  List<CourseModel> coursesToReturn = [];
  bool shouldThrow = false;

  @override
  Future<List<CourseModel>> fetchCourses({
    bool simulateFailure = false,
    bool simulateEmpty = false,
  }) async {
    if (shouldThrow || simulateFailure) {
      throw Exception('Remote server error');
    }
    if (simulateEmpty) return [];
    return coursesToReturn;
  }
}

class FakeCourseLocalDataSource implements CourseLocalDataSource {
  List<CourseModel> memoryStorage = [];

  @override
  Future<List<CourseModel>> getCachedCourses() async => List.from(memoryStorage);

  @override
  Future<void> cacheCourses(List<CourseModel> courses) async {
    memoryStorage = List.from(courses);
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    final idx = memoryStorage.indexWhere((c) => c.id == course.id);
    if (idx != -1) {
      memoryStorage[idx] = course;
    } else {
      memoryStorage.add(course);
    }
  }

  @override
  bool hasCachedCourses() => memoryStorage.isNotEmpty;

  @override
  Future<void> clearCache() async {
    memoryStorage.clear();
  }
}

class FakeNetworkInfo implements NetworkInfo {
  final RxBool _connectedRx = true.obs;

  bool get connected => _connectedRx.value;
  set connected(bool val) => _connectedRx.value = val;

  @override
  RxBool get isConnectedRx => _connectedRx;

  @override
  bool get isConnected => _connectedRx.value;

  @override
  bool get isSimulatedOffline => !_connectedRx.value;

  @override
  Stream<bool> get onConnectivityChanged => _connectedRx.stream;

  @override
  void setSimulatedOffline(bool offline) {
    _connectedRx.value = !offline;
  }

  @override
  void toggleOffline() {
    _connectedRx.value = !_connectedRx.value;
  }
}

void main() {
  late CourseRepositoryImpl repository;
  late FakeCourseRemoteDataSource fakeRemoteDataSource;
  late FakeCourseLocalDataSource fakeLocalDataSource;
  late FakeNetworkInfo fakeNetworkInfo;

  final sampleCourse = CourseModel(
    id: 1,
    title: 'Python Programming',
    instructor: 'John Smith',
    progress: 50,
    lessons: 2,
    lessonList: const [
      LessonModel(id: 1, title: 'Intro', isCompleted: true),
      LessonModel(id: 2, title: 'Basics', isCompleted: false),
    ],
  );

  setUp(() {
    fakeRemoteDataSource = FakeCourseRemoteDataSource();
    fakeLocalDataSource = FakeCourseLocalDataSource();
    fakeNetworkInfo = FakeNetworkInfo();

    repository = CourseRepositoryImpl(
      remoteDataSource: fakeRemoteDataSource,
      localDataSource: fakeLocalDataSource,
      networkInfo: fakeNetworkInfo,
    );
  });

  group('CourseRepository Offline-First Architecture Tests', () {
    test('When online, fetches from remote and caches to local storage', () async {
      fakeNetworkInfo.connected = true;
      fakeRemoteDataSource.coursesToReturn = [sampleCourse];

      final result = await repository.getCourses();

      expect(result, isA<Success<List<CourseModel>>>());
      final courses = (result as Success<List<CourseModel>>).data;
      expect(courses.length, 1);
      expect(courses.first.title, 'Python Programming');

      // Verify cached into local data source
      expect(fakeLocalDataSource.hasCachedCourses(), isTrue);
      expect(fakeLocalDataSource.memoryStorage.first.title, 'Python Programming');
    });

    test('When offline, serves previously cached courses', () async {
      // Pre-seed local cache
      fakeLocalDataSource.memoryStorage = [sampleCourse];

      // Simulate device is offline
      fakeNetworkInfo.connected = false;

      final result = await repository.getCourses();

      expect(result, isA<Success<List<CourseModel>>>());
      final courses = (result as Success<List<CourseModel>>).data;
      expect(courses.length, 1);
      expect(courses.first.id, 1);
    });

    test('When offline and cache is empty, returns descriptive Failure', () async {
      fakeNetworkInfo.connected = false;
      fakeLocalDataSource.memoryStorage = [];

      final result = await repository.getCourses();

      expect(result, isA<Failure<List<CourseModel>>>());
      final failure = result as Failure<List<CourseModel>>;
      expect(failure.statusCode, 503);
      expect(failure.message, contains('No internet connection'));
    });

    test('When online but remote API fails, gracefully falls back to local cache', () async {
      fakeLocalDataSource.memoryStorage = [sampleCourse];
      fakeNetworkInfo.connected = true;
      fakeRemoteDataSource.shouldThrow = true; // Remote throws 500 error

      final result = await repository.getCourses();

      // Gracefully falls back to cache
      expect(result, isA<Success<List<CourseModel>>>());
      final courses = (result as Success<List<CourseModel>>).data;
      expect(courses.first.title, 'Python Programming');
    });
  });
}
