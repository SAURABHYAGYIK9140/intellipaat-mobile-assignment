import 'package:get/get.dart';
import '../../data/models/course_model.dart';
import '../../domain/repositories/course_repository.dart';
import 'dashboard_controller.dart';

class CourseDetailsController extends GetxController {
  final CourseRepository _courseRepository;

  CourseDetailsController({required CourseRepository courseRepository})
      : _courseRepository = courseRepository;

  late final Rx<CourseModel> course;

  @override
  void onInit() {
    super.onInit();
    final courseArg = Get.arguments as CourseModel;
    course = courseArg.obs;
  }

  Future<void> toggleLessonCompletion(int lessonId) async {
    // 1. Update lesson status and dynamically recalculate progress
    final updatedCourse = course.value.withToggledLesson(lessonId);
    course.value = updatedCourse;

    // 2. Persist updated course state to local offline cache
    await _courseRepository.updateCourse(updatedCourse);

    // 3. Keep dashboard in sync
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateCourseInList(updatedCourse);
    }
  }
}
