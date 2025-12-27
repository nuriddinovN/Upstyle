// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:up_style/core/routes/app_router.dart';
import 'package:up_style/core/theme/app_theme.dart';
import 'package:up_style/features/auth/presentation/provider/auth_provider.dart';
import '../widgets/auth_button.dart';
import '../widgets/social_auth_buttons.dart';
import '../widgets/upstyle_logo.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
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
                  'Set up your Upstyle account',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  )
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 40),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

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
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Sign Up Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return AuthButton(
                      text: 'Sign Up',
                      isLoading: authProvider.isLoading,
                      onPressed: () => _handleSignUp(authProvider),
                    );
                  },
                ),

                const SizedBox(height: 24),

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

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push(AppRouter.login);
                      },
                      child: Text(
                        'Login',
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

  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
    );

    if (authProvider.status == AuthStatus.emailNotVerified) {
      if (mounted) {
        _showEmailVerificationDialog();
      }
    } else if (authProvider.status == AuthStatus.authenticated) {
      if (mounted) {
        context.go(AppRouter.main);
      }
    }
  }

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Verify Your Email'),
        content: const Text(
          'We\'ve sent a verification email to your address. Please check your email and click the verification link to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppRouter.login);
            },
            child: const Text('Go to Login'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthProvider>().sendEmailVerification();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Verification email sent!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Resend Email'),
          ),
        ],
      ),
    );
  }
}
