// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Third-party quick login buttons: Google, GitHub, SmartDolphin, Facebook and
/// Apple.
///
/// Demo behaviour: any button enters directly without verification.
class SocialLoginButtons extends StatelessWidget {
  /// Called with the chosen provider's name.
  final void Function(String provider) onSocialLogin;

  const SocialLoginButtons({super.key, required this.onSocialLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialCircle(
          onTap: () => onSocialLogin('Google'),
          background: Colors.white,
          child: SvgPicture.string(_googleSvg, width: 23, height: 23),
        ),
        const SizedBox(width: 10),
        _SocialCircle(
          onTap: () => onSocialLogin('GitHub'),
          background: Colors.white,
          child: SvgPicture.string(_githubSvg, width: 20, height: 20),
        ),
        const SizedBox(width: 10),
        _SocialCircle(
          onTap: () => onSocialLogin('SmartDolphin'),
          background: Colors.white,
          child: const Text(
            'S',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 10),
        _SocialCircle(
          onTap: () => onSocialLogin('Facebook'),
          background: const Color(0xFF1877F2),
          child: SvgPicture.string(_facebookSvg, width: 16, height: 16),
        ),
        const SizedBox(width: 10),
        _SocialCircle(
          onTap: () => onSocialLogin('Apple'),
          background: Colors.black,
          child: SvgPicture.string(_appleSvg, width: 18, height: 18),
        ),
      ],
    );
  }

  /// Official Google four-colour G (48 viewport).
  static const String _googleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
<path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z"/>
<path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,6.306,14.691z"/>
<path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z"/>
<path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z"/>
</svg>''';

  /// Official GitHub mark (16 viewport).
  static const String _githubSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
<path fill="#1B1817" d="M8 0C3.58 0 0 3.58 0 8c0,3.54 2.29,6.53 5.47,7.59 0.4,0.07 0.55-0.17 0.55-0.38 0-0.19-0.01-0.82-0.01-1.49-2.01,0.37-2.53-0.49-2.69-0.94-0.09-0.23-0.48-0.94-0.82-1.13-0.28-0.15-0.68-0.52-0.01-0.53 0.63-0.01 1.08,0.58 1.23,0.82 0.72,1.21 1.87,0.87 2.33,0.66 0.07-0.52 0.28-0.87 0.51-1.07-1.78-0.2-3.64-0.89-3.64-3.95 0-0.87 0.31-1.59 0.82-2.15-0.08-0.2-0.36-1.02 0.08-2.12 0,0 0.67-0.21 2.2,0.82 0.64-0.18 1.32-0.27 2-0.27 0.68,0 1.36,0.09 2,0.27 1.53-1.04 2.2-0.82 2.2-0.82 0.44,1.1 0.16,1.92 0.08,2.12 0.51,0.56 0.82,1.27 0.82,2.15 0,3.07-1.87,3.75-3.65,3.95 0.29,0.25 0.54,0.73 0.54,1.48 0,1.07-0.01,1.93-0.01,2.2 0,0.21 0.15,0.46 0.55,0.38A8.013,8.013 0 0 0 16,8c0-4.42-3.58-8-8-8z"/>
</svg>''';

  /// Facebook mark (320 x 512 viewport).
  static const String _facebookSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512">
<path fill="#FFFFFF" d="M279.14 288l14.22-92.66h-88.91v-60.13c0-25.35 12.42-50.06 52.84-50.06h40.42V6.26S260.43 0 225.36 0c-73.22 0-121.08 44.38-121.08 124.72v70.62H22.89V288h81.39v224h100.17V288z"/>
</svg>''';

  /// Apple mark (384 x 512 viewport).
  static const String _appleSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 384 512">
<path fill="#FFFFFF" d="M318.7 268.7c-.2-36.7 16.4-64.4 50-84.8-18.8-26.9-47.2-41.7-84.7-44.6-35.5-2.8-74.3 20.7-88.5 20.7-15 0-49.4-19.7-76.4-19.7C63.3 141.2 4 184.8 4 273.5q0 39.3 14.4 81.2c12.8 36.7 59 126.7 107.2 125.2 25.2-.6 43-17.9 75.8-17.9 31.8 0 48.3 17.9 76.4 17.9 48.6-.7 90.4-82.5 102.6-119.3-65.2-30.7-61.7-90-61.7-91.9zm-56.6-164.2c27.3-32.4 24.8-61.9 24-72.5-24.1 1.4-52 16.4-67.9 34.9-17.5 19.8-27.8 44.3-25.6 71.9 26.1 2 49.9-11.4 69.5-34.3z"/>
</svg>''';
}

/// Circular third-party login button.
class _SocialCircle extends StatelessWidget {
  final VoidCallback onTap;
  final Color background;
  final Widget child;

  const _SocialCircle({
    required this.onTap,
    required this.background,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
