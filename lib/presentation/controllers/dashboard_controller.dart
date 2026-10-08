import 'package:get/get.dart';
import '../../core/network/api_result.dart';
import '../../core/network/network_info.dart';
import '../../data/models/course_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../routes/app_routes.dart';

class DashboardController extends GetxController with StateMixin<List<CourseModel>> {
  final CourseRepository _courseRepository;
  final AuthRepository _authRepository;
  final NetworkInfo _networkInfo;

  DashboardController({
    required CourseRepository courseRepository,
    required AuthRepository authRepository,
    required NetworkInfo networkInfo,
  })  : _courseRepository = courseRepository,
        _authRepository = authRepository,
        _networkInfo = networkInfo;

  final RxBool isOffline = false.obs;
  final RxBool simulateFailure = false.obs;
  final RxBool simulateEmpty = false.obs;
  final RxBool isRefreshing = false.obs;
  Worker? _connectivityWorker;

  @override
  void onInit() {
    super.onInit();
    isOffline.value = !_networkInfo.isConnected;

    // React synchronously to real device or simulated connectivity state changes
    _connectivityWorker = ever<bool>(_networkInfo.isConnectedRx, (connected) {
      final wasOffline = isOffline.value;
      isOffline.value = !connected;

      if (wasOffline && connected) {
        // Automatically sync fresh data when network reconnects
        loadCourses(forceRefresh: true);
      } else if (!connected) {
        // Disconnected: serve from local cache
        loadCourses();
      }
    });

    loadCourses();
  }

  Future<void> loadCourses({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      change(null, status: RxStatus.loading());
    } else {
      isRefreshing.value = true;
    }

    final result = await _courseRepository.getCourses(
      forceRefresh: forceRefresh,
      simulateFailure: simulateFailure.value,
      simulateEmpty: simulateEmpty.value,
    );

    isRefreshing.value = false;

    if (result is Success<List<CourseModel>>) {
      final courses = result.data;
      if (courses.isEmpty) {
        change([], status: RxStatus.empty());
      } else {
        change(courses, status: RxStatus.success());
      }
    } else if (result is Failure<List<CourseModel>>) {
      change(null, status: RxStatus.error(result.message));
    }
  }

  void toggleSimulatedOffline() {
    _networkInfo.toggleOffline();
  }

  void toggleSimulateFailure() {
    simulateFailure.value = !simulateFailure.value;
    if (simulateFailure.value) {
      simulateEmpty.value = false;
    }
    loadCourses();
  }

  void toggleSimulateEmpty() {
    simulateEmpty.value = !simulateEmpty.value;
    if (simulateEmpty.value) {
      simulateFailure.value = false;
    }
    loadCourses();
  }

  void updateCourseInList(CourseModel updatedCourse) {
    if (state != null) {
      final currentList = List<CourseModel>.from(state!);
      final index = currentList.indexWhere((c) => c.id == updatedCourse.id);
      if (index != -1) {
        currentList[index] = updatedCourse;
        change(currentList, status: RxStatus.success());
      }
    }
  }

  void openCourseDetails(CourseModel course) {
    Get.toNamed(AppRoutes.courseDetails, arguments: course);
  }

  Future<void> logout() async {
    await _authRepository.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    _connectivityWorker?.dispose();
    super.onClose();
  }
}
