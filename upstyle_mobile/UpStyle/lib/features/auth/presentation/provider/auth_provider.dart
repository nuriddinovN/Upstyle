import 'package:flutter/foundation.dart';
import 'package:up_style/core/di/injection_container.dart';
import 'package:up_style/features/auth/domain/entities/user.dart';
import 'package:up_style/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:up_style/features/auth/domain/usecases/signin_use_case.dart';
import 'package:up_style/features/auth/domain/usecases/signup_use_case.dart';
import 'package:up_style/features/home/domain/usecases/get_categories_use_case.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Use cases
  final SignUpUseCase _signUpUseCase = sl<SignUpUseCase>();
  final SignInUseCase _signInUseCase = sl<SignInUseCase>();
  final SignOutUseCase _signOutUseCase = sl<SignOutUseCase>();
  final GetCurrentUserUseCase _getCurrentUserUseCase =
      sl<GetCurrentUserUseCase>();
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase =
      sl<SendEmailVerificationUseCase>();
  final SendPasswordResetUseCase _sendPasswordResetUseCase =
      sl<SendPasswordResetUseCase>();
  final InitializeDefaultCategoriesUseCase _initializeDefaultCategoriesUseCase =
      sl<InitializeDefaultCategoriesUseCase>();

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        _setStatus(AuthStatus.unauthenticated);
        _setError(failure.message);
      },
      (user) {
        if (user != null) {
          _user = user;
          if (user.emailVerified) {
            _setStatus(AuthStatus.authenticated);
            _initializeDefaultCategories();
          } else {
            _setStatus(AuthStatus.emailNotVerified);
          }
        } else {
          _setStatus(AuthStatus.unauthenticated);
        }
      },
    );

    _setLoading(false);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _signUpUseCase(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) {
        _setStatus(AuthStatus.error);
        _setError(failure.message);
      },
      (user) {
        _user = user;
        _setStatus(AuthStatus.emailNotVerified);
        sendEmailVerification(); // Automatically send verification email
      },
    );

    _setLoading(false);
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    final result = await _signInUseCase(
      email: email,
      password: password,
    );

    result.fold(
      (failure) {
        _setStatus(AuthStatus.error);
        _setError(failure.message);
      },
      (user) {
        _user = user;
        if (user.emailVerified) {
          _setStatus(AuthStatus.authenticated);
          _initializeDefaultCategories();
        } else {
          _setStatus(AuthStatus.emailNotVerified);
        }
      },
    );

    _setLoading(false);
  }

  Future<void> signOut() async {
    _setLoading(true);

    final result = await _signOutUseCase();

    result.fold(
      (failure) {
        _setError(failure.message);
      },
      (_) {
        _user = null;
        _setStatus(AuthStatus.unauthenticated);
      },
    );

    _setLoading(false);
  }

  Future<void> sendEmailVerification() async {
    final result = await _sendEmailVerificationUseCase();

    result.fold(
      (failure) => _setError(failure.message),
      (_) => {}, // Success handled silently
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    final result = await _sendPasswordResetUseCase(email);

    result.fold(
      (failure) => _setError(failure.message),
      (_) => {}, // Success - UI should show success message
    );

    _setLoading(false);
  }

  Future<void> checkEmailVerification() async {
    _setLoading(true);
    _clearError();

    try {
      // Force reload current user from Firebase Auth
      await _getCurrentUserUseCase();

      final result = await _getCurrentUserUseCase();

      result.fold(
        (failure) {
          _setError('Error checking verification: ${failure.message}');
        },
        (user) {
          if (user != null && user.emailVerified) {
            _user = user;
            _setStatus(AuthStatus.authenticated);
            _initializeDefaultCategories();
            _clearError();
          } else {
            _setError(
                'Email not yet verified. Please check your email and click the verification link.');
          }
        },
      );
    } catch (e) {
      _setError('Error checking email verification: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh user data from Firestore
  /// Used after becoming a creator or switching modes to get updated user data
  Future<void> refreshUser() async {
    _clearError();

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        _setError('Failed to refresh user: ${failure.message}');
      },
      (user) {
        if (user != null) {
          _user = user;
          // Update status if needed
          if (user.emailVerified && _status != AuthStatus.authenticated) {
            _setStatus(AuthStatus.authenticated);
          }
          notifyListeners();
        }
      },
    );
  }

  Future<void> _initializeDefaultCategories() async {
    await _initializeDefaultCategoriesUseCase();
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() => _clearError();
}
