import 'package:get/get.dart';
import '../../domain/repositories/course_repository.dart';
import '../controllers/course_details_controller.dart';

class CourseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseDetailsController>(
      () => CourseDetailsController(
        courseRepository: Get.find<CourseRepository>(),
      ),
    );
  }
}
