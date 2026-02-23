import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<UserModel?> login(String phone, String password) async {
    // Mocking Firebase Auth
    await Future.delayed(const Duration(seconds: 2));
    if (phone == '1234567890') {
      return const UserModel(
        id: '1',
        name: 'John Doe',
        phone: '1234567890',
        role: UserRole.user,
        address: 'HSR Layout, Bangalore',
      );
    } else if (phone == '0987654321') {
      return const UserModel(
        id: '2',
        name: 'Partner Jack',
        phone: '0987654321',
        role: UserRole.partner,
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return null; // For now
  }
}
