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

  void _confirmSignOut() {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        actions: [
          IconButton(
            tooltip: 'Network status',
            icon: Obx(
              () => Icon(
                controller.isOffline.value ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                color: controller.isOffline.value ? AppColors.warning : AppColors.success,
              ),
            ),
            onPressed: controller.toggleSimulatedOffline,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
            tooltip: 'More options',
            onSelected: (value) {
              if (value == 'offline') controller.toggleSimulatedOffline();
              if (value == 'error') controller.toggleSimulateFailure();
              if (value == 'empty') controller.toggleSimulateEmpty();
              if (value == 'logout') _confirmSignOut();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'offline',
                child: Text(controller.isOffline.value ? 'Go Online' : 'Simulate Offline'),
              ),
              PopupMenuItem(
                value: 'error',
                child: Text(controller.simulateFailure.value ? 'Reset API' : 'Simulate API Error'),
              ),
              PopupMenuItem(
                value: 'empty',
                child: Text(controller.simulateEmpty.value ? 'Reset List' : 'Simulate Empty List'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sign Out', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadCourses(forceRefresh: true),
          color: AppColors.primary,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Offline status banner (only displays when offline)
                Obx(
                  () => OfflineBanner(
                    isOffline: controller.isOffline.value,
                    onToggleOffline: controller.toggleSimulatedOffline,
                  ),
                ),

                // Dynamic UI states via StateMixin
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
    );
  }

  Widget _buildCourseList(List<CourseModel> courses) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
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

  Widget _buildLoadingState() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
