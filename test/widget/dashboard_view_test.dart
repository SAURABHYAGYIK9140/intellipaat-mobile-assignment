import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:learning_dashboard/data/models/course_model.dart';
import 'package:learning_dashboard/domain/repositories/auth_repository.dart';
import 'package:learning_dashboard/data/repositories/course_repository_impl.dart';
import 'package:learning_dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:learning_dashboard/presentation/views/dashboard/dashboard_view.dart';
import '../unit/course_repository_test.dart';

class MockAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('DashboardView renders without any RenderFlex overflow', (tester) async {
    // Set standard phone viewport size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.resetPhysicalSize);

    Get.reset();

    final fakeRemote = FakeCourseRemoteDataSource();
    final fakeLocal = FakeCourseLocalDataSource();
    final fakeNet = FakeNetworkInfo();

    fakeRemote.coursesToReturn = [
      const CourseModel(
        id: 1,
        title: 'Python Programming',
        instructor: 'John Smith',
        progress: 65,
        lessons: 20,
      ),
    ];

    final controller = DashboardController(
      courseRepository: CourseRepositoryImpl(
        remoteDataSource: fakeRemote,
        localDataSource: fakeLocal,
        networkInfo: fakeNet,
      ),
      authRepository: MockAuthRepository(),
      networkInfo: fakeNet,
    );

    Get.put<DashboardController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: DashboardView(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('My Courses'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
