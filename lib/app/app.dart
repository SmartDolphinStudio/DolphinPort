// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';

import 'routes.dart';
import 'theme.dart';

/// Root application widget: global theme and centralised routing.
class DolphinPortApp extends StatelessWidget {
  const DolphinPortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DolphinPort',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      home: const SplashScreen(),
      onGenerateRoute: appOnGenerateRoute,
    );
  }

  /// Builds the global light theme from the shared design tokens.
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.black,
      colorScheme: const ColorScheme.light(
        primary: AppColors.black,
        surface: AppColors.white,
      ),
      dividerColor: AppColors.divider,
    );
  }
}
