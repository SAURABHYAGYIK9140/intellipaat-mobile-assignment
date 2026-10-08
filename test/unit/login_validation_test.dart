import 'package:flutter_test/flutter_test.dart';
import 'package:learning_dashboard/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns error when email is null or empty', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('   '), isNotNull);
    });

    test('validateEmail returns error for invalid email formats', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('user@'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
      expect(Validators.validateEmail('user@domain'), isNotNull);
    });

    test('validateEmail returns null for valid email formats', () {
      expect(Validators.validateEmail('learner@example.com'), isNull);
      expect(Validators.validateEmail('john.doe@company.org'), isNull);
      expect(Validators.validateEmail('student+extra@university.edu'), isNull);
    });

    test('validatePassword returns error when password is empty or short', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('12345'), isNotNull);
    });

    test('validatePassword returns null when password is 6 or more characters', () {
      expect(Validators.validatePassword('123456'), isNull);
      expect(Validators.validatePassword('password123'), isNull);
    });
  });
}
