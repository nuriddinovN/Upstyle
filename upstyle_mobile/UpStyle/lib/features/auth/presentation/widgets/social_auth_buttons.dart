import 'package:flutter/material.dart';
import 'package:up_style/core/theme/app_theme.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            text: 'Continue with\nGoogle',
            backgroundColor: AppTheme.googleButton,
            textColor: AppTheme.textPrimary,
            icon: _buildGoogleIcon(),
            onPressed: () {
              // TODO: Handle Google sign in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Google Sign-In not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            text: 'Continue with\nFacebook',
            backgroundColor: AppTheme.facebookButton,
            textColor: Colors.white,
            icon: const Icon(Icons.facebook, color: Colors.white, size: 24),
            onPressed: () {
              // TODO: Handle Facebook sign in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Facebook Sign-In not implemented yet'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Stack(
        children: [
          // Google "G" logo representation
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: const Center(
                child: Text(
                  'G',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Widget icon;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          side: BorderSide(
            color: backgroundColor == Colors.white
                ? AppTheme.inputBorder
                : backgroundColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
