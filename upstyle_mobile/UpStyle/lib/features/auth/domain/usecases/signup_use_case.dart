import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    // Basic validation
    if (email.isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Please enter a valid email'));
    }

    if (password.length < 6) {
      return const Left(
          ValidationFailure('Password must be at least 6 characters'));
    }

    if (name.isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    return await repository.signUp(
      email: email,
      password: password,
      name: name,
    );
  }
}
