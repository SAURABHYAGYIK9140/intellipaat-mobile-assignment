import 'package:get/get.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/course_local_datasource.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/course_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Network Info Service
    Get.put<NetworkInfo>(NetworkInfoImpl(), permanent: true);

    // Data Sources
    Get.lazyPut<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<CourseRemoteDataSource>(() => CourseRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<CourseLocalDataSource>(() => CourseLocalDataSourceImpl(), fenix: true);

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: Get.find<AuthRemoteDataSource>(),
      ),
      fenix: true,
    );

    Get.lazyPut<CourseRepository>(
      () => CourseRepositoryImpl(
        remoteDataSource: Get.find<CourseRemoteDataSource>(),
        localDataSource: Get.find<CourseLocalDataSource>(),
        networkInfo: Get.find<NetworkInfo>(),
      ),
      fenix: true,
    );
  }
}
