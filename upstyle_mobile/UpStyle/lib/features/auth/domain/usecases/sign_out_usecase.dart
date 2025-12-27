import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.signOut();
  }
}

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, User?>> call() async {
    return await repository.getCurrentUser();
  }
}

class SendEmailVerificationUseCase {
  final AuthRepository repository;

  SendEmailVerificationUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.sendEmailVerification();
  }
}

class SendPasswordResetUseCase {
  final AuthRepository repository;

  SendPasswordResetUseCase(this.repository);

  Future<Either<Failure, void>> call(String email) async {
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email'));
    }

    return await repository.sendPasswordResetEmail(email);
  }
}
