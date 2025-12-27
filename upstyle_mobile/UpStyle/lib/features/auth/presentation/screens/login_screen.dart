import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/routes/app_router.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/upstyle_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                const UpstyleLogo(),

                const SizedBox(height: 12),

                // Title
                Text(
                  'Log In to your Upstyle account',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 40),

                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot password?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Log In Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: 'Log In',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleLogin(authProvider),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Email verification notice
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.status == AuthStatus.emailNotVerified) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Please verify your email address to continue.',
                              style: TextStyle(color: Colors.orange),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () {
                                authProvider.sendEmailVerification();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Verification email sent!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              child: const Text('Resend Verification Email'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  authProvider.checkEmailVerification(),
                              child: const Text('I\'ve Verified My Email'),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Divider with text
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppTheme.inputBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or you can just',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppTheme.inputBorder)),
                  ],
                ),

                const SizedBox(height: 24),

                // Social Auth Buttons
                const SocialAuthButtons(),

                const SizedBox(height: 24),

                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(AppRouter.signup);
                      },
                      child: Text(
                        'Sign Up',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                              color: AppTheme.orangeAccent,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Error message
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.errorMessage != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (authProvider.status == AuthStatus.authenticated) {
      if (mounted) {
        context.go(AppRouter.main);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                context.read<AuthProvider>().sendPasswordResetEmail(
                      emailController.text.trim(),
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password reset email sent!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}
