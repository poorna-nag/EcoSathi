import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final _logger = Logger();

  AuthRepositoryImpl({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  // Helper to convert phone to dummy email for Firebase Auth
  String _phoneToEmail(String phone) => '$phone@ecosathi.com';

  @override
  Future<UserModel?> login(String phone, String password) async {
    _logger.d('Attempting login for phone: $phone');
    try {
      final email = _phoneToEmail(phone);
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _logger.d('Firebase Auth success for: ${userCredential.user!.uid}');
        final doc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        if (doc.exists) {
          _logger.d('Firestore user data found');
          return UserModel.fromMap(doc.data()!, doc.id);
        } else {
          _logger.e('User authenticated but no Firestore document found');
        }
      }
      return null;
    } catch (e) {
      _logger.e('Login error: ${e.toString()}');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _logger.d('Attempting registration for: $phone as $role');
    try {
      final email = _phoneToEmail(phone);

      // 1. Create user in Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        _logger.d('Firebase Auth user created: ${userCredential.user!.uid}');
        final newUser = UserModel(
          id: userCredential.user!.uid,
          name: name,
          phone: phone,
          role: role,
          email: email,
        );

        // 2. Save user data to Firestore
        _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap())
            .then((_) => _logger.d('Firestore data saved successfully'))
            .catchError((e) => _logger.e('Firestore save failed: $e'));

        return newUser;
      }
      return null;
    } catch (e) {
      _logger.e('Registration error: ${e.toString()}');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    _logger.d('Logging out user: ${_firebaseAuth.currentUser?.uid}');
    await _firebaseAuth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      _logger.d('Session found for user: ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        _logger.e('Session exists but no Firestore data found');
      }
    } else {
      _logger.d('No active session found');
    }
    return null;
  }
}
