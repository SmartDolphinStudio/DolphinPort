// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolphinport/app/app.dart';
import 'package:dolphinport/widgets/transaction_tile.dart';
import 'package:dolphinport/widgets/visa_card.dart';

void main() {
  /// Sets the test viewport to a logical size with a device pixel ratio of 1.
  void setViewport(WidgetTester tester, double width, double height) {
    tester.view
      ..devicePixelRatio = 1.0
      ..physicalSize = Size(width, height);
    addTearDown(tester.view.reset);
  }

  /// Advances past the splash hold and slide to reach the login screen.
  Future<void> passSplash(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
  }

  /// Enters the demo credentials, submits and advances through loading and
  /// the slide transition to reach the home screen.
  Future<void> loginToHome(WidgetTester tester) async {
    await passSplash(tester);
    await tester.enterText(find.byType(TextField).first, 'demo@dolphinport.il');
    await tester.enterText(find.byType(TextField).last, 'demo1234');
    await tester.tap(find.widgetWithText(AnimatedContainer, 'Login'));
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump();
  }

  testWidgets('boots: splash brand then login screen', (tester) async {
    setViewport(tester, 360, 667);
    await tester.pumpWidget(const DolphinPortApp());

    // The splash shows the full brand name first.
    expect(find.text('DOLPHINPORT'), findsOneWidget);
    await passSplash(tester);

    // Then the login screen appears.
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email, phone, name, UID or ID'), findsOneWidget);
  });

  testWidgets('login reaches home with header, card and transactions', (
    tester,
  ) async {
    setViewport(tester, 390, 844);
    await tester.pumpWidget(const DolphinPortApp());
    await loginToHome(tester);

    // The home header, card and transaction list are built.
    expect(find.text('Available balance'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.byType(TransactionTile), findsWidgets);

    // After the balance animation, the amount settles at 100,000,000.
    await tester.pump(const Duration(milliseconds: 1700));
    final amountRect = tester.getRect(find.text(r'$100,000,000'));
    final cardRect = tester.getRect(find.byType(VisaCard));
    // The top of the card must not overlap the bottom of the amount.
    expect(cardRect.top, greaterThanOrEqualTo(amountRect.bottom - 1));
  });

  testWidgets('opens transaction detail from a home transaction', (
    tester,
  ) async {
    setViewport(tester, 390, 844);
    await tester.pumpWidget(const DolphinPortApp());
    await loginToHome(tester);

    await tester.tap(find.byType(TransactionTile).first);
    await tester.pumpAndSettle();

    // The detail screen title.
    expect(find.text('Transaction'), findsOneWidget);

    // Billing services and the footer are built only after scrolling.
    await tester.scrollUntilVisible(find.text('Billing services'), 80);
    expect(find.text('Billing services'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Powered by DolphinPort'), 80);
    expect(find.text('Powered by DolphinPort'), findsOneWidget);
  });

  for (final size in const [Size(360, 667), Size(430, 932)]) {
    testWidgets('home fits ${size.width}x${size.height} viewport', (
      tester,
    ) async {
      setViewport(tester, size.width, size.height);
      await tester.pumpWidget(const DolphinPortApp());
      await loginToHome(tester);

      expect(find.text('Recent transactions'), findsOneWidget);
      expect(find.byType(TransactionTile), findsWidgets);
    });
  }
}
