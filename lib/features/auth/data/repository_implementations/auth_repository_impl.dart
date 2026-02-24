import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  // Simple in-memory storage for demo purposes
  static final Map<String, UserModel> _mockUsers = {
    '1234567890': const UserModel(
      id: '1',
      name: 'John Doe',
      phone: '1234567890',
      role: UserRole.user,
      address: 'HSR Layout, Bangalore',
    ),
    '0987654321': const UserModel(
      id: '2',
      name: 'Partner Jack',
      phone: '0987654321',
      role: UserRole.partner,
    ),
  };

  @override
  Future<UserModel?> login(String phone, String password) async {
    // Mocking Firebase Auth
    await Future.delayed(const Duration(seconds: 2));

    // In a real app, we'd also verify the password
    if (_mockUsers.containsKey(phone)) {
      return _mockUsers[phone];
    }
    return null;
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // Mocking Firebase Auth
    await Future.delayed(const Duration(seconds: 2));

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      phone: phone,
      role: role,
    );

    // Save to our in-memory "database"
    _mockUsers[phone] = newUser;

    return newUser;
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
