// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import 'login_curve_clipper.dart';

/// Black curved header shared by every authentication screen (login, sign up,
/// forgot password and reset password), so they read as one consistent layout.
class AuthHeaderBackground extends StatelessWidget {
  /// One-line helper text shown beneath the brand wordmark.
  final String subtitle;

  const AuthHeaderBackground({super.key, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: LoginCurveClipper(),
      child: Container(
        width: double.infinity,
        height: size.height,
        color: Colors.black,
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DOLPHINPORT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF5C5C5C),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
