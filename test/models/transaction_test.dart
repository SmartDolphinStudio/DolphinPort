// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolphinport/models/transaction.dart';

void main() {
  group('Transaction', () {
    test('marks income transactions', () {
      final timestamp = DateTime(2026, 9, 21, 9, 41);
      final transaction = Transaction(
        title: 'Salary',
        subtitle: 'Today, 9:41am',
        amount: 3200,
        type: TxType.income,
        category: 'Income',
        icon: Icons.business_center_outlined,
        timestamp: timestamp,
      );

      expect(transaction.isIncome, isTrue);
      expect(transaction.timestamp, timestamp);
      expect(transaction.amount, 3200);
    });

    test('marks expense transactions', () {
      final transaction = Transaction(
        title: 'Bills',
        subtitle: 'Today, 8:15am',
        amount: 1200,
        type: TxType.expense,
        category: 'Bills',
        icon: Icons.receipt_long_outlined,
        timestamp: DateTime(2026, 9, 21, 8, 15),
      );

      expect(transaction.isIncome, isFalse);
    });
  });
}
