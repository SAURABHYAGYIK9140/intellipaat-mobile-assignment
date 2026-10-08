import 'package:get_storage/get_storage.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/network/api_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final GetStorage _storage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    GetStorage? storage,
  })  : _remoteDataSource = remoteDataSource,
        _storage = storage ?? GetStorage();

  @override
  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.login(email: email, password: password);
      // Persist session
      await _storage.write(StorageKeys.authUser, user.toJson());
      await _storage.write(StorageKeys.authToken, user.token);
      await _storage.write(StorageKeys.isLoggedIn, true);
      return Success(user);
    } catch (e) {
      return Failure(
        message: e.toString().replaceFirst('Exception: ', ''),
        originalException: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.remove(StorageKeys.authUser);
    await _storage.remove(StorageKeys.authToken);
    await _storage.write(StorageKeys.isLoggedIn, false);
  }

  @override
  bool isLoggedIn() {
    return _storage.read<bool>(StorageKeys.isLoggedIn) ?? false;
  }

  @override
  UserModel? getCurrentUser() {
    final raw = _storage.read(StorageKeys.authUser);
    if (raw != null && raw is Map) {
      return UserModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }
}
