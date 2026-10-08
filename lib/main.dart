import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/storage_keys.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bindings/initial_binding.dart';
import 'presentation/routes/app_pages.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline persistent local key-value storage
  await GetStorage.init();

  final storage = GetStorage();
  final isLoggedIn = storage.read<bool>(StorageKeys.isLoggedIn) ?? false;

  runApp(LearningDashboardApp(
    initialRoute: isLoggedIn ? AppRoutes.dashboard : AppRoutes.login,
  ));
}

class LearningDashboardApp extends StatelessWidget {
  final String initialRoute;

  const LearningDashboardApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      initialRoute: initialRoute,
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
    );
  }
}
