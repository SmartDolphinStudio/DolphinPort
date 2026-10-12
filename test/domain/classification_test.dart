// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter_test/flutter_test.dart';

import 'package:dolphinport/domain/category_resolver.dart';
import 'package:dolphinport/domain/mcc_table.dart';
import 'package:dolphinport/domain/random_expense.dart';
import 'package:dolphinport/domain/tx_breakdown.dart';
import 'package:dolphinport/domain/tx_category.dart';
import 'package:dolphinport/models/transaction.dart';

Transaction _expense(
  double amount,
  TxCategory category, {
  bool crossBorder = false,
}) {
  return Transaction(
    title: 'Counterparty',
    subtitle: '',
    amount: amount,
    type: TxType.expense,
    category: category.code,
    icon: category.icon,
    timestamp: DateTime(2026, 1, 1),
    id: 'TX-${category.code}-$amount',
    crossBorder: crossBorder,
  );
}

void main() {
  const resolver = CategoryResolver();
  const calculator = BreakdownCalculator();

  group('CategoryResolver', () {
    test('MCC is authoritative and beats the merchant name', () {
      final resolution = resolver.resolve(
        mcc: '5411',
        merchantName: 'Some Random Technology Company',
      );
      expect(resolution.category, TxCategory.groceries);
      expect(resolution.source, CategorySource.mcc);
      expect(resolution.confidence, greaterThan(0.9));
    });

    test('falls back to a name keyword rule without an MCC', () {
      final resolution = resolver.resolve(merchantName: 'Netflix Streaming');
      expect(resolution.category, TxCategory.subscription);
      expect(resolution.source, CategorySource.nameRule);
    });

    test('uses the legacy category for seeded entries', () {
      final resolution = resolver.resolve(
        legacyCategory: 'Food',
        title: 'Lunch',
      );
      expect(resolution.category, TxCategory.dining);
      expect(resolution.source, CategorySource.legacy);
    });

    test('never hard-guesses when no signal exists', () {
      final resolution = resolver.resolve();
      expect(resolution.category, TxCategory.uncategorised);
      expect(resolution.source, CategorySource.none);
      expect(resolution.isUncertain, isTrue);
    });

    test('MCC table resolves known range codes', () {
      expect(MccTable.categoryFor('5812'), TxCategory.dining);
      expect(MccTable.categoryFor('4112'), TxCategory.transport);
      expect(MccTable.categoryFor('9999'), isNull);
    });
  });

  group('BreakdownCalculator', () {
    test('net plus tax plus fees always equals the gross amount', () {
      final categories = TxCategory.values.where((c) => !c.isIncome);
      for (final category in categories) {
        for (final gross in [1.0, 5.07, 49.99, 1234.56, 9999.99]) {
          final breakdown = calculator.calculate(
            _expense(gross, category),
            category,
          );
          final reconciled = roundToCents(
            breakdown.net + breakdown.taxTotal + breakdown.feeTotal,
          );
          expect(
            reconciled,
            closeTo(gross, 0.001),
            reason: '${category.code} at $gross',
          );
        }
      }
    });

    test('cross-border transactions expose fees and FX information', () {
      final breakdown = calculator.calculate(
        _expense(500, TxCategory.travel, crossBorder: true),
        TxCategory.travel,
      );
      expect(breakdown.fx, isNotNull);
      expect(breakdown.fees.length, greaterThanOrEqualTo(2));
      expect(breakdown.fx!.currency, isNotEmpty);
    });

    test('the same transaction always produces identical figures', () {
      final tx = _expense(83.42, TxCategory.dining);
      final first = calculator.calculate(tx, TxCategory.dining);
      final second = calculator.calculate(tx, TxCategory.dining);
      expect(second.net, first.net);
      expect(second.taxTotal, first.taxTotal);
      expect(second.feeTotal, first.feeTotal);
    });
  });

  group('RandomExpenseGenerator', () {
    test('every generated transaction is an outgoing expense', () {
      final generator = RandomExpenseGenerator();
      for (var i = 0; i < 200; i++) {
        final tx = generator.next();
        expect(tx.type, TxType.expense);
        expect(tx.amount, greaterThan(0));
        expect(tx.mcc, isNotNull);
        expect(tx.id, isNotEmpty);
      }
    });
  });
}
