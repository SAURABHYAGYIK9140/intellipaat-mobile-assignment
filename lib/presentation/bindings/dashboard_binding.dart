import 'package:get/get.dart';
import '../../core/network/network_info.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/course_repository.dart';
import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        courseRepository: Get.find<CourseRepository>(),
        authRepository: Get.find<AuthRepository>(),
        networkInfo: Get.find<NetworkInfo>(),
      ),
    );
  }
}
