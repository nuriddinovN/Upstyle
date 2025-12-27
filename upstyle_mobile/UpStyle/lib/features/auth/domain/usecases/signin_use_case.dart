import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email'));
    }

    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty'));
    }

    return await repository.signIn(
      email: email,
      password: password,
    );
  }
}
