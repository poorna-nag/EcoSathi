import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String phone, String password);
  Future<UserModel?> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
