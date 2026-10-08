import '../../core/network/api_result.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<ApiResult<UserModel>> login({required String email, required String password});
  Future<void> logout();
  bool isLoggedIn();
  UserModel? getCurrentUser();
}
