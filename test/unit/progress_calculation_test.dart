import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/data/models/course_model.dart';
import 'package:learning_dashboard/data/models/lesson_model.dart';

void main() {
  group('Course Progress Calculation Logic Tests', () {
    test('calculateProgressPercentage returns 0 when lesson list is empty', () {
      final progress = CourseModel.calculateProgressPercentage([]);
      expect(progress, 0);
    });

    test('calculateProgressPercentage correctly computes rounded percentages', () {
      final lessons = [
        const LessonModel(id: 1, title: 'Lesson 1', isCompleted: true),
        const LessonModel(id: 2, title: 'Lesson 2', isCompleted: false),
        const LessonModel(id: 3, title: 'Lesson 3', isCompleted: false),
        const LessonModel(id: 4, title: 'Lesson 4', isCompleted: false),
      ];

      // 1 out of 4 = 25%
      expect(CourseModel.calculateProgressPercentage(lessons), 25);

      final updatedLessons = [
        const LessonModel(id: 1, title: 'Lesson 1', isCompleted: true),
        const LessonModel(id: 2, title: 'Lesson 2', isCompleted: true),
        const LessonModel(id: 3, title: 'Lesson 3', isCompleted: false),
        const LessonModel(id: 4, title: 'Lesson 4', isCompleted: false),
      ];

      // 2 out of 4 = 50%
      expect(CourseModel.calculateProgressPercentage(updatedLessons), 50);

      final completedAll = [
        const LessonModel(id: 1, title: 'Lesson 1', isCompleted: true),
        const LessonModel(id: 2, title: 'Lesson 2', isCompleted: true),
        const LessonModel(id: 3, title: 'Lesson 3', isCompleted: true),
        const LessonModel(id: 4, title: 'Lesson 4', isCompleted: true),
      ];

      // 4 out of 4 = 100%
      expect(CourseModel.calculateProgressPercentage(completedAll), 100);
    });

    test('withToggledLesson updates completion status and recalculates course progress', () {
      final initialCourse = CourseModel(
        id: 1,
        title: 'Python Programming',
        instructor: 'John Smith',
        progress: 0,
        lessons: 4,
        lessonList: const [
          LessonModel(id: 1, title: 'Intro', isCompleted: false),
          LessonModel(id: 2, title: 'Syntax', isCompleted: false),
          LessonModel(id: 3, title: 'OOP', isCompleted: false),
          LessonModel(id: 4, title: 'Async', isCompleted: false),
        ],
      );

      expect(initialCourse.progress, 0);

      // Toggle lesson 1 to completed
      final courseAfterLesson1 = initialCourse.withToggledLesson(1);
      expect(courseAfterLesson1.lessonList.firstWhere((l) => l.id == 1).isCompleted, isTrue);
      expect(courseAfterLesson1.progress, 25);

      // Toggle lesson 2 to completed
      final courseAfterLesson2 = courseAfterLesson1.withToggledLesson(2);
      expect(courseAfterLesson2.lessonList.firstWhere((l) => l.id == 2).isCompleted, isTrue);
      expect(courseAfterLesson2.progress, 50);

      // Toggle lesson 1 back to pending (uncompleted)
      final courseAfterUncheckingLesson1 = courseAfterLesson2.withToggledLesson(1);
      expect(courseAfterUncheckingLesson1.lessonList.firstWhere((l) => l.id == 1).isCompleted, isFalse);
      expect(courseAfterUncheckingLesson1.progress, 25);
    });
  });
}
