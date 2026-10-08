import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate real network request latency
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulate invalid credentials error if test error password is used
    if (password == 'wrongpassword' || password == 'error123') {
      throw Exception('Invalid email or password. Please check your credentials.');
    }

    // Return authenticated user profile and mock JWT token
    return UserModel(
      id: 'usr_847291',
      email: email.trim().toLowerCase(),
      name: _deriveNameFromEmail(email),
      token: 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  String _deriveNameFromEmail(String email) {
    try {
      final namePart = email.split('@').first;
      final clean = namePart.replaceAll(RegExp(r'[._-]'), ' ');
      return clean
          .split(' ')
          .map((part) => part.isNotEmpty ? '${part[0].toUpperCase()}${part.substring(1)}' : '')
          .join(' ');
    } catch (_) {
      return 'Senior Learner';
    }
  }
}
