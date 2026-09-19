// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Direction of funds for a transaction.
enum TxType { income, expense }

/// A single wallet transaction.
///
/// Core fields ([title], [amount], [type], [category], [icon] and
/// [timestamp]) are always present. Classification and settlement metadata
/// ([id], [mcc], [currencyCode] and [crossBorder]) is optional, so the
/// original seeded entries continue to construct unchanged; transactions
/// created by the scanner provide it.
class Transaction {
  final String title;
  final String subtitle;
  final double amount;
  final TxType type;
  final String category;
  final IconData icon;
  final DateTime timestamp;

  /// Stable identifier used to derive deterministic fee and tax rows.
  /// Empty for seeded entries, which then fall back to a content-based seed.
  final String id;

  /// Merchant Category Code carried by the clearing record, if known.
  final String? mcc;

  /// ISO 4217 settlement currency code; the demo account settles in USD.
  final String currencyCode;

  /// Whether the merchant country or currency differs from the account.
  final bool crossBorder;

  const Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.category,
    required this.icon,
    required this.timestamp,
    this.id = '',
    this.mcc,
    this.currencyCode = 'USD',
    this.crossBorder = false,
  });

  /// Whether the transaction represents income.
  bool get isIncome => type == TxType.income;

  /// Stable seed used for deterministic, per-transaction calculations.
  String get stableSeed =>
      id.isNotEmpty
          ? id
          : '$title|${timestamp.microsecondsSinceEpoch}|$amount';
}
