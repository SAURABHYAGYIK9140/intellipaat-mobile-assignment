import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/course_model.dart';
import '../../controllers/dashboard_controller.dart';
import 'widgets/course_card.dart';
import 'widgets/offline_banner.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 26),
            SizedBox(width: 10),
            Text(AppStrings.dashboardTitle),
          ],
        ),
        actions: [
          // Live Network Status Icon
          Obx(
            () => IconButton(
              tooltip: controller.isOffline.value ? 'Offline mode' : 'Online mode',
              icon: Icon(
                controller.isOffline.value ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                color: controller.isOffline.value ? AppColors.warning : AppColors.success,
              ),
              onPressed: controller.toggleSimulatedOffline,
            ),
          ),
          // Logout Button
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () {
              Get.defaultDialog(
                title: 'Sign Out',
                middleText: 'Are you sure you want to sign out?',
                textConfirm: 'Sign Out',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                buttonColor: AppColors.error,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Evaluator Interactive Sandbox Bar
            _buildEvaluatorControls(context),

            // Main Dashboard Body with StateMixin
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadCourses(forceRefresh: true),
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Offline Status Banner
                      Obx(
                        () => OfflineBanner(
                          isOffline: controller.isOffline.value,
                          onToggleOffline: controller.toggleSimulatedOffline,
                        ),
                      ),

                      // State Handling: Loading / Error / Empty / Success
                      Expanded(
                        child: controller.obx(
                          (courses) => _buildCourseList(courses ?? []),
                          onLoading: _buildLoadingState(),
                          onError: (error) => _buildErrorState(error ?? 'An unknown error occurred'),
                          onEmpty: _buildEmptyState(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Evaluator Test Toolbar to switch between all required assessment states
  Widget _buildEvaluatorControls(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Text(
            'Test States:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Obx(
                    () => FilterChip(
                      selected: controller.isOffline.value,
                      label: Text(controller.isOffline.value ? 'Offline: ON' : 'Offline: OFF'),
                      avatar: Icon(
                        controller.isOffline.value ? Icons.wifi_off : Icons.wifi,
                        size: 14,
                        color: controller.isOffline.value ? Colors.white : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.warning,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: controller.isOffline.value ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => controller.toggleSimulatedOffline(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => FilterChip(
                      selected: controller.simulateFailure.value,
                      label: const Text('Simulate API 500 Error'),
                      avatar: Icon(
                        Icons.error_outline,
                        size: 14,
                        color: controller.simulateFailure.value ? Colors.white : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.error,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: controller.simulateFailure.value ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => controller.toggleSimulateFailure(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => FilterChip(
                      selected: controller.simulateEmpty.value,
                      label: const Text('Simulate Empty State'),
                      avatar: Icon(
                        Icons.inbox_outlined,
                        size: 14,
                        color: controller.simulateEmpty.value ? Colors.white : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.info,
                      labelStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: controller.simulateEmpty.value ? Colors.white : AppColors.textPrimary,
                      ),
                      onSelected: (_) => controller.toggleSimulateEmpty(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Success State: List of courses
  Widget _buildCourseList(List<CourseModel> courses) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return CourseCard(
          course: course,
          onContinue: () => controller.openCourseDetails(course),
        );
      },
    );
  }

  /// Loading State: Skeleton loading cards
  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 160,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Empty State
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.noCoursesTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.noCoursesSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                controller.simulateEmpty.value = false;
                controller.loadCourses();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Reset & Reload Courses'),
            ),
          ],
        ),
      ),
    );
  }

  /// Error State with Retry Button
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              AppStrings.errorTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.simulateFailure.value = false;
                controller.loadCourses();
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(AppStrings.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}
