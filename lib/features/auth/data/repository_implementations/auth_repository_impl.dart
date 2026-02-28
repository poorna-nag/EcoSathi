import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> login(String identifier, String password) async {
    final cleanIdentifier = identifier.trim();
    final cleanPassword = password.trim();

    if (cleanIdentifier.isEmpty || cleanPassword.isEmpty) {
      throw 'Please enter both identifier and password';
    }

    try {
      UserCredential userCredential;

      // Check if identifier is an email
      if (cleanIdentifier.contains('@')) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: cleanIdentifier,
          password: cleanPassword,
        );
      } else {
        // For phone login, look up the email associated with the phone in Firestore first.
        final querySnapshot = await _firestore
            .collection('users')
            .where('phone', isEqualTo: cleanIdentifier)
            .get();

        if (querySnapshot.docs.isEmpty) {
          throw 'No user found with this phone number. Please register first.';
        }

        final userDoc = querySnapshot.docs.first;
        final email = userDoc.data()['email'];

        if (email == null) {
          throw 'Profile error: No email associated with this phone number.';
        }

        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: cleanPassword,
        );
      }

      if (userCredential.user != null) {
        final user = await _getUserFromFirestore(userCredential.user!.uid);
        if (user == null) {
          throw 'User profile not found in database. Contact support.';
        }
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email.';
        case 'wrong-password':
          throw 'Incorrect password. Try again.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        case 'user-disabled':
          throw 'This user account has been disabled.';
        case 'too-many-requests':
          throw 'Too many attempts. Please try again later.';
        default:
          throw e.message ?? 'Authentication failed. Please try again.';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw 'Connection error: Firebase service is unavailable. Please check your internet connection and ensure Firestore is enabled in your Firebase console.';
      }
      throw 'Database error: ${e.message}';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final cleanEmail = email.trim();
    final cleanPhone = phone.trim();
    final cleanName = name.trim();

    if (cleanEmail.isEmpty ||
        cleanPhone.isEmpty ||
        cleanName.isEmpty ||
        password.isEmpty) {
      throw 'All fields are required';
    }

    try {
      // 1. Check if phone already exists in Firestore (since Auth only checks email)
      final phoneCheck = await _firestore
          .collection('users')
          .where('phone', isEqualTo: cleanPhone)
          .get();

      if (phoneCheck.docs.isNotEmpty) {
        throw 'This phone number is already registered.';
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (userCredential.user != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          name: cleanName,
          email: cleanEmail,
          phone: cleanPhone,
          role: role,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'This email is already registered.';
        case 'weak-password':
          throw 'The password is too weak.';
        case 'invalid-email':
          throw 'The email address is badly formatted.';
        default:
          throw e.message ?? 'Registration failed. Please try again.';
      }
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw 'Connection error: Firebase service is unavailable. Please check your internet connection and ensure Firestore is enabled in your Firebase console.';
      }
      if (e.code == 'permission-denied') {
        throw 'Database error: Access denied. Please ensure Firestore rules are set to test mode.';
      }
      throw 'Database error: ${e.message}';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserFromFirestore(user.uid);
    }
    return null;
  }

  Future<UserModel?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') {
        throw 'Connection error: Firebase service is unavailable. Please check your internet connection.';
      }
      rethrow;
    }
  }
}
