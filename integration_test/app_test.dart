// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

// Smoke integration test: boots the app, signs in with the demo credentials
// and verifies that the primary destinations can be reached.
//
// Run on a connected device or emulator with:
//   flutter test integration_test/app_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dolphinport/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('signs in and opens the transactions and analytics screens', (
    tester,
  ) async {
    await tester.pumpWidget(const DolphinPortApp());

    // Advance past the splash screen.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    // Sign in with any non-empty demo credentials.
    await tester.enterText(find.byType(TextField).first, 'demo@dolphinport.il');
    await tester.enterText(find.byType(TextField).last, 'demo1234');
    await tester.tap(find.widgetWithText(AnimatedContainer, 'Login'));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();

    expect(find.text('Available balance'), findsOneWidget);

    // Open the transactions screen from the See all entry.
    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsOneWidget);

    // Reach the analytics screen.
    await tester.tap(find.text('View charts'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsOneWidget);
  });
}
