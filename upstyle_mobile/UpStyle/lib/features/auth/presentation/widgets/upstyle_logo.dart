import 'package:flutter/material.dart';

class UpstyleLogo extends StatelessWidget {
  const UpstyleLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logos/up_style_full_logo.png',
          height: 60,
          width: 200,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
