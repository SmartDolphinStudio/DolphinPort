// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../core/clock.dart';
import 'chart_data.dart';
import 'transaction.dart';

/// Deterministic, in-memory data source.
///
/// With no back end, every balance, transaction and chart series is generated
/// locally. The home screen shows [homeTransactionCount] entries; the
/// transactions screen shows the complete list.
class MockData {
  MockData._();

  /// Number of transactions shown on the home screen.
  static const int homeTransactionCount = 24;

  /// Total number of transactions generated for the transactions screen.
  static const int totalTransactionCount = 58;

  /// Abbreviated month names.
  static const List<String> _monthAbbr = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// All transactions, generated lazily so the data stays reproducible.
  static final List<Transaction> transactions = _generate();

  /// Builds the full list: six fixed recent entries, then templated entries.
  static List<Transaction> _generate() {
    final now = Clock.now();
    final today = DateTime(now.year, now.month, now.day);

    /// Returns [day] at the given hour and minute.
    DateTime at(DateTime day, int hour, int minute) =>
        DateTime(day.year, day.month, day.day, hour, minute);

    /// Returns a time today that is [minutesAgo] minutes in the past,
    /// clamped just after midnight so it never lands in the future or on the
    /// previous day.
    DateTime pastToday(int minutesAgo) {
      final candidate = now.subtract(Duration(minutes: minutesAgo));
      return candidate.isBefore(today)
          ? today.add(const Duration(minutes: 5))
          : candidate;
    }

    final salaryTime = pastToday(20);
    final billsTime = pastToday(90);

    final list = <Transaction>[
      Transaction(
        title: 'Salary',
        subtitle: subtitleFor(salaryTime),
        amount: 3200,
        type: TxType.income,
        category: 'Income',
        icon: Icons.business_center_outlined,
        timestamp: salaryTime,
      ),
      Transaction(
        title: 'Bills',
        subtitle: subtitleFor(billsTime),
        amount: 1200,
        type: TxType.expense,
        category: 'Bills',
        icon: Icons.receipt_long_outlined,
        timestamp: billsTime,
      ),
      Transaction(
        title: 'Top up',
        subtitle: 'Yesterday, 12:07pm',
        amount: 2400,
        type: TxType.income,
        category: 'Income',
        icon: Icons.add,
        timestamp: at(today.subtract(const Duration(days: 1)), 12, 7),
      ),
      Transaction(
        title: 'Transfer',
        subtitle: 'Yesterday, 4:07pm',
        amount: 1050,
        type: TxType.expense,
        category: 'Transfer',
        icon: Icons.arrow_outward,
        timestamp: at(today.subtract(const Duration(days: 1)), 16, 7),
      ),
      Transaction(
        title: 'Shopping',
        subtitle: 'Sep 16, 6:30pm',
        amount: 850,
        type: TxType.expense,
        category: 'Shopping',
        icon: Icons.shopping_bag_outlined,
        timestamp: at(today.subtract(const Duration(days: 5)), 18, 30),
      ),
      Transaction(
        title: 'Food',
        subtitle: 'Sep 16, 7:45pm',
        amount: 38,
        type: TxType.expense,
        category: 'Food',
        icon: Icons.restaurant_outlined,
        timestamp: at(today.subtract(const Duration(days: 5)), 19, 45),
      ),
    ];

    var index = 0;
    while (list.length < totalTransactionCount) {
      final template = _templates[index % _templates.length];
      final amounts = template.amounts;
      final amount = amounts[(index ~/ _templates.length) % amounts.length]
          .toDouble();
      // Move back one day for every three entries; stagger the time.
      final date = now.subtract(
        Duration(
          days: 2 + index ~/ 3,
          hours: (index * 5) % 12,
          minutes: (index * 17) % 60,
        ),
      );
      list.add(
        Transaction(
          title: template.title,
          subtitle: subtitleFor(date),
          amount: amount,
          type: template.type,
          category: template.category,
          icon: template.icon,
          timestamp: date,
        ),
      );
      index++;
    }
    return list;
  }

  /// Formats a timestamp as a list subtitle: "Today, 9:41am",
  /// "Yesterday, 4:07pm" or "Sep 15, 4:07pm".
  static String subtitleFor(DateTime date) {
    final now = Clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final daysAgo = today.difference(day).inDays;

    final hour12 = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final ampm = date.hour < 12 ? 'am' : 'pm';
    final minute = date.minute.toString().padLeft(2, '0');
    final time = '$hour12:$minute$ampm';

    if (daysAgo == 0) return 'Today, $time';
    if (daysAgo == 1) return 'Yesterday, $time';
    return '${_monthAbbr[date.month - 1]} ${date.day}, $time';
  }

  /// Templates used for the generated entries.
  static const List<_TxTemplate> _templates = [
    _TxTemplate('Food', 'Food', TxType.expense, Icons.restaurant_outlined, [
      12,
      28,
      45,
      63,
      88,
    ]),
    _TxTemplate(
      'Transport',
      'Transport',
      TxType.expense,
      Icons.directions_car_outlined,
      [8, 15, 22, 35],
    ),
    _TxTemplate(
      'Shopping',
      'Shopping',
      TxType.expense,
      Icons.shopping_bag_outlined,
      [45, 88, 120, 230, 450],
    ),
    _TxTemplate('Bills', 'Bills', TxType.expense, Icons.receipt_long_outlined, [
      60,
      120,
      240,
      480,
    ]),
    _TxTemplate(
      'Subscription',
      'Entertainment',
      TxType.expense,
      Icons.subscriptions_outlined,
      [9, 15, 19],
    ),
    _TxTemplate('Transfer', 'Transfer', TxType.expense, Icons.arrow_outward, [
      120,
      300,
      500,
      1050,
    ]),
    _TxTemplate('Top up', 'Income', TxType.income, Icons.add, [
      500,
      1000,
      2400,
    ]),
    _TxTemplate(
      'Investment',
      'Income',
      TxType.income,
      Icons.trending_up_rounded,
      [200, 600],
    ),
    _TxTemplate('Refund', 'Income', TxType.income, Icons.undo_rounded, [
      25,
      60,
      120,
    ]),
  ];

  /// Income and expense for the last six months.
  static const List<MonthPoint> monthly = [
    MonthPoint('Apr', 5200, 4800),
    MonthPoint('May', 6100, 5500),
    MonthPoint('Jun', 5800, 5100),
    MonthPoint('Jul', 6800, 6200),
    MonthPoint('Aug', 7200, 6500),
    MonthPoint('Sep', 6800, 6800),
  ];

  /// Expense category slices for the pie chart.
  static const List<CategorySlice> categorySlices = [
    CategorySlice('Bills', 0.30, Color(0xFF111111)),
    CategorySlice('Shopping', 0.22, Color(0xFF6B7280)),
    CategorySlice('Transfer', 0.18, Color(0xFF9CA3AF)),
    CategorySlice('Food', 0.15, Color(0xFFD1D5DB)),
    CategorySlice('Entertainment', 0.10, Color(0xFFE5E7EB)),
    CategorySlice('Transport', 0.05, Color(0xFFF3F4F6)),
  ];

  /// Expense ranking (sums to 6,800).
  static const List<RankItem> expenseRank = [
    RankItem('Bills', 2040, Color(0xFF111111), Icons.receipt_long_outlined),
    RankItem('Shopping', 1496, Color(0xFF374151), Icons.shopping_bag_outlined),
    RankItem('Transfer', 1224, Color(0xFF6B7280), Icons.swap_horiz),
    RankItem('Food', 1020, Color(0xFF9CA3AF), Icons.restaurant_outlined),
    RankItem(
      'Entertainment',
      680,
      Color(0xFFD1D5DB),
      Icons.sports_esports_outlined,
    ),
    RankItem(
      'Transport',
      340,
      Color(0xFFE5E7EB),
      Icons.directions_car_outlined,
    ),
  ];

  /// Income ranking (sums to 6,800).
  static const List<RankItem> incomeRank = [
    RankItem('Salary', 4200, Color(0xFF111111), Icons.business_center_outlined),
    RankItem('Top up', 2000, Color(0xFF6B7280), Icons.add),
    RankItem('Investment', 600, Color(0xFF9CA3AF), Icons.trending_up_rounded),
  ];

  /// Total income, computed from the transactions.
  static double get totalIncome => transactions
      .where((t) => t.type == TxType.income)
      .fold(0, (sum, t) => sum + t.amount);

  /// Total expense, computed from the transactions.
  static double get totalExpense => transactions
      .where((t) => t.type == TxType.expense)
      .fold(0, (sum, t) => sum + t.amount);
}

/// Template used to generate a transaction.
class _TxTemplate {
  final String title;
  final String category;
  final TxType type;
  final IconData icon;
  final List<int> amounts;

  const _TxTemplate(
    this.title,
    this.category,
    this.type,
    this.icon,
    this.amounts,
  );
}
