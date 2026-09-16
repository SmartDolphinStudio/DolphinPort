// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/charts/charts_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/transactions/all_transactions_screen.dart';
import '../screens/transactions/transaction_detail_screen.dart';

/// Centralised, typed route names used across the application.
abstract final class RouteNames {
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String allTransactions = '/transactions';
  static const String transactionDetail = '/transaction';
  static const String analytics = '/analytics';
}

/// Builds the page associated with [settings].
///
/// The transaction detail route expects a [Transaction] provided through
/// [RouteSettings.arguments].
Route<dynamic> appOnGenerateRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (context) {
      switch (settings.name) {
        case RouteNames.login:
          return const LoginScreen();
        case RouteNames.forgotPassword:
          return const ForgotPasswordScreen();
        case RouteNames.resetPassword:
          return const ResetPasswordScreen();
        case RouteNames.home:
          return const HomeScreen();
        case RouteNames.allTransactions:
          return const AllTransactionsScreen();
        case RouteNames.analytics:
          return const ChartsScreen();
        case RouteNames.transactionDetail:
          final transaction = settings.arguments as Transaction;
          return TransactionDetailScreen(tx: transaction);
        default:
          return const HomeScreen();
      }
    },
  );
}
