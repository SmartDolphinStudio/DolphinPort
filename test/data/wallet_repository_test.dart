// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolphinport/core/clock.dart';
import 'package:dolphinport/data/repositories/wallet_repository.dart';
import 'package:dolphinport/models/chart_data.dart';

void main() {
  // Pin the demo clock to a fixed Monday for every test so the reporting
  // windows stay deterministic regardless of the real date.
  setUp(() => Clock.setSource(() => DateTime(2026, 9, 21, 11)));
  tearDown(Clock.reset);

  const repository = InMemoryWalletRepository();

  List<String> titles(TransactionRange range, {DateTimeRange? custom}) =>
      repository
          .transactionsInRange(range, custom: custom)
          .map((t) => t.title)
          .toList();

  group('InMemoryWalletRepository lists', () {
    test('returns the full and home-only lists', () {
      expect(repository.allTransactions(), hasLength(58));
      expect(repository.recentTransactions(), hasLength(24));
    });

    test('filters today to the two fixed entries', () {
      expect(titles(TransactionRange.today), ['Salary', 'Bills']);
    });

    test('treats Monday as the start of the week', () {
      // The demo "today" is a Monday, so the week contains only the two
      // entries dated today.
      expect(titles(TransactionRange.thisWeek), ['Salary', 'Bills']);
    });

    test('nests the reporting windows', () {
      final today = repository.transactionsInRange(TransactionRange.today);
      final week = repository.transactionsInRange(TransactionRange.thisWeek);
      final month = repository.transactionsInRange(TransactionRange.thisMonth);
      final year = repository.transactionsInRange(TransactionRange.thisYear);

      expect(today.length, lessThanOrEqualTo(week.length));
      expect(week.length, lessThanOrEqualTo(month.length));
      expect(month.length, lessThanOrEqualTo(year.length));
      expect(year, hasLength(58));
      expect(
        titles(TransactionRange.thisMonth),
        containsAll([
          'Salary',
          'Bills',
          'Top up',
          'Transfer',
          'Shopping',
          'Food',
        ]),
      );
    });

    test('filters a custom range by timestamp', () {
      final now = Clock.now();
      DateTime dayAt(int dayOffset, int hour, [int minute = 0]) =>
          DateTime(now.year, now.month, now.day - dayOffset, hour, minute);

      final yesterdayOnly = DateTimeRange(
        start: dayAt(1, 0),
        end: dayAt(1, 23, 59),
      );
      expect(titles(TransactionRange.custom, custom: yesterdayOnly), [
        'Top up',
        'Transfer',
      ]);

      final distantPast = DateTimeRange(
        start: DateTime(now.year - 2),
        end: DateTime(now.year - 1),
      );
      expect(
        repository.transactionsInRange(
          TransactionRange.custom,
          custom: distantPast,
        ),
        isEmpty,
      );
    });
  });

  group('InMemoryWalletRepository aggregates', () {
    test('includes the fixed entries in the totals', () {
      expect(repository.totalIncome(), greaterThanOrEqualTo(3200 + 2400));
      expect(
        repository.totalExpense(),
        greaterThanOrEqualTo(1200 + 1050 + 850 + 38),
      );
    });

    test('sums the monthly series', () {
      final series = repository.monthlySeries();
      final income = series.fold<double>(0, (sum, m) => sum + m.income);
      final expense = series.fold<double>(0, (sum, m) => sum + m.expense);

      expect(income, 37900);
      expect(expense, 34900);
    });

    test('sums the rankings to 6,800', () {
      double amountSum(List<RankItem> items) =>
          items.fold<double>(0, (sum, item) => sum + item.amount);

      expect(amountSum(repository.incomeRanking()), 6800);
      expect(amountSum(repository.expenseRanking()), 6800);
    });

    test('sums the expense slices to one', () {
      final total = repository.expenseSlices().fold<double>(
        0,
        (sum, slice) => sum + slice.value,
      );
      expect(total, closeTo(1.0, 1e-9));
    });
  });
}
