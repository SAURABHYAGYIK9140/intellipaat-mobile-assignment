import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../bindings/course_details_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../views/auth/login_view.dart';
import '../views/course_details/course_details_view.dart';
import '../views/dashboard/dashboard_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.courseDetails,
      page: () => const CourseDetailsView(),
      binding: CourseDetailsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
  ];
}
