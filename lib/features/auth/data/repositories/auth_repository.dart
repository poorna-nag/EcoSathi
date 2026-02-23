import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String phone, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
