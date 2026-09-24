// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../../core/clock.dart';
import '../../models/chart_data.dart';
import '../../models/mock_data.dart';
import '../../models/transaction.dart';

/// Pre-set reporting windows offered by the transactions screen.
enum TransactionRange { today, thisWeek, thisMonth, thisYear, custom }

/// Read-only boundary between the UI and wallet data.
///
/// In this demo the only implementation is [InMemoryWalletRepository], which
/// reads from [MockData]. A future build could add a network-backed
/// implementation without changing the screens.
abstract interface class WalletRepository {
  /// Transactions shown on the home screen.
  List<Transaction> recentTransactions();

  /// Every transaction, unfiltered.
  List<Transaction> allTransactions();

  /// Inserts a new transaction at the head of the ledger, for example one
  /// produced by the scanner.
  void addTransaction(Transaction transaction);

  /// Transactions that fall within the given reporting window.
  ///
  /// [custom] is required when [range] is [TransactionRange.custom].
  List<Transaction> transactionsInRange(
    TransactionRange range, {
    DateTimeRange? custom,
  });

  /// Total income across all transactions.
  double totalIncome();

  /// Total expense across all transactions.
  double totalExpense();

  /// Monthly income and expense series for the charts.
  List<MonthPoint> monthlySeries();

  /// Expense category slices for the pie chart.
  List<CategorySlice> expenseSlices();

  /// Expense ranking for the analytics screen.
  List<RankItem> expenseRanking();

  /// Income ranking for the analytics screen.
  List<RankItem> incomeRanking();
}

/// [WalletRepository] backed by the deterministic [MockData] source.
class InMemoryWalletRepository implements WalletRepository {
  const InMemoryWalletRepository();

  @override
  List<Transaction> recentTransactions() =>
      MockData.transactions.take(MockData.homeTransactionCount).toList();

  @override
  List<Transaction> allTransactions() =>
      List<Transaction>.unmodifiable(MockData.transactions);

  @override
  void addTransaction(Transaction transaction) =>
      MockData.transactions.insert(0, transaction);

  @override
  List<Transaction> transactionsInRange(
    TransactionRange range, {
    DateTimeRange? custom,
  }) {
    if (range == TransactionRange.custom) {
      if (custom == null) return allTransactions();
      return MockData.transactions
          .where(
            (t) =>
                !t.timestamp.isBefore(custom.start) &&
                !t.timestamp.isAfter(custom.end),
          )
          .toList();
    }

    final now = Clock.now();
    final today = DateTime(now.year, now.month, now.day);
    late final DateTime start;
    switch (range) {
      case TransactionRange.today:
        start = today;
      case TransactionRange.thisWeek:
        // The reporting week starts on Monday.
        start = today.subtract(Duration(days: today.weekday - 1));
      case TransactionRange.thisMonth:
        start = DateTime(now.year, now.month);
      case TransactionRange.thisYear:
        start = DateTime(now.year);
      case TransactionRange.custom:
        start = today;
    }

    return MockData.transactions
        .where(
          (t) =>
              !DateTime(
                t.timestamp.year,
                t.timestamp.month,
                t.timestamp.day,
              ).isBefore(start) &&
              !t.timestamp.isAfter(now),
        )
        .toList();
  }

  @override
  double totalIncome() => MockData.totalIncome;

  @override
  double totalExpense() => MockData.totalExpense;

  @override
  List<MonthPoint> monthlySeries() => MockData.monthly;

  @override
  List<CategorySlice> expenseSlices() => MockData.categorySlices;

  @override
  List<RankItem> expenseRanking() => MockData.expenseRank;

  @override
  List<RankItem> incomeRanking() => MockData.incomeRank;
}

/// Shared repository instance used by the application.
const WalletRepository walletRepository = InMemoryWalletRepository();
