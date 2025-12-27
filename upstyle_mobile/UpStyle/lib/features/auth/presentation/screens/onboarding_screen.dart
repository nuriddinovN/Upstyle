// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:up_style/core/routes/app_router.dart';
import 'package:up_style/core/theme/app_theme.dart';
import '../widgets/auth_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),

              // Title
              RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  style: Theme.of(context).textTheme.displayMedium,
                  children: [
                    const TextSpan(text: 'Match every style\n'),
                    const TextSpan(text: 'with your '),
                    TextSpan(
                      text: 'personality!',
                      style: TextStyle(
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [
                              Color(0xFF0066FF), // Blue
                              Color(0xFFFF0099), // Pink/Magenta
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(
                            const Rect.fromLTWH(100, 100, 250, 0),
                          ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Hating the clothes in your wardrobe?\nDon\'t worry! Find the best stylist here.',
                textAlign: TextAlign.start,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(
                    height: 1.25,
                    fontWeight: FontWeight.w400,
                    color: CupertinoColors.inactiveGray),
              ),

              const Spacer(flex: 1),

              Image.asset(
                'assets/images/welcome_page_image.png',
                height: 250,
                fit: BoxFit.contain,
              ),
              const Spacer(flex: 1),

              // Get Started Button
              AuthButton(
                text: 'Get Started',
                onPressed: () {
                  context.push(AppRouter.signup);
                },
              ),

              const SizedBox(height: 16),

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Container(
      width: 70,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.inputBorder),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 2,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
