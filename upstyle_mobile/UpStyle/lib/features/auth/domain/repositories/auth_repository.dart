import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, void>> sendEmailVerification();

  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  Future<Either<Failure, void>> updateUserProfile({
    String? name,
    String? profileImageUrl,
  });

  Stream<User?> get authStateChanges;

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> signInWithFacebook();
}
