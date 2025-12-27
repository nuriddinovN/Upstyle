import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updateUserProfile({
    String? name,
    String? profileImageUrl,
  });

  Stream<UserModel?> get authStateChanges;
}

class FirebaseAuthDataSource implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthDataSource({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user');
      }

      final now = DateTime.now();
      final userModel = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        createdAt: now,
        updatedAt: now,
        emailVerified: credential.user!.emailVerified,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw ServerFailure('Failed to sign up: $e');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to sign in');
      }

      return await _getUserFromFirestore(credential.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw ServerFailure('Failed to sign in: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerFailure('Failed to sign out: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Reload user to get fresh emailVerified status from Firebase Auth
      await firebaseUser.reload();
      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) return null;

      // Get user data from Firestore
      final userModel = await _getUserFromFirestore(refreshedUser.uid);

      // CRITICAL FIX: Sync emailVerified status from Firebase Auth to Firestore
      if (refreshedUser.emailVerified != userModel.emailVerified) {
        await _firestore.collection('users').doc(refreshedUser.uid).update({
          'emailVerified': refreshedUser.emailVerified,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Return updated model
        return userModel.copyWith(emailVerified: refreshedUser.emailVerified);
      }

      return userModel;
    } catch (e) {
      throw ServerFailure('Failed to get current user: $e');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthFailure('No user logged in');
      }

      await user.sendEmailVerification();
    } catch (e) {
      throw ServerFailure('Failed to send email verification: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    } catch (e) {
      throw ServerFailure('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> updateUserProfile({
    String? name,
    String? profileImageUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthFailure('No user logged in');
      }

      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

      await _firestore.collection('users').doc(user.uid).update(updates);
    } catch (e) {
      throw ServerFailure('Failed to update user profile: $e');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    // Get fresh Firebase Auth user
    final firebaseUser = _firebaseAuth.currentUser;
    await firebaseUser?.reload();
    final refreshedFirebaseUser = _firebaseAuth.currentUser;

    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists) {
      throw NotFoundFailure('User data not found');
    }

    final userModel = UserModel.fromFirestore(doc);

    // ALWAYS use Firebase Auth's emailVerified status (source of truth)
    return userModel.copyWith(
      emailVerified: refreshedFirebaseUser?.emailVerified ?? false,
    );
  }

  Failure _mapFirebaseException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return const AuthFailure('The password provided is too weak.');
      case 'email-already-in-use':
        return const AuthFailure('The account already exists for that email.');
      case 'user-not-found':
        return const AuthFailure('No user found for that email.');
      case 'wrong-password':
        return const AuthFailure('Wrong password provided.');
      case 'invalid-email':
        return const AuthFailure('The email address is not valid.');
      case 'user-disabled':
        return const AuthFailure('This user account has been disabled.');
      case 'too-many-requests':
        return const AuthFailure('Too many requests. Please try again later.');
      case 'operation-not-allowed':
        return const AuthFailure('Operation not allowed.');
      default:
        return AuthFailure('Authentication failed: ${e.message}');
    }
  }
}
