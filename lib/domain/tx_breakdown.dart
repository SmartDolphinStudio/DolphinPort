// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import '../models/transaction.dart';
import 'tx_category.dart';

/// Small, deterministic pseudo-random generator (mulberry32).
///
/// Fee and tax rows are derived from a transaction's stable seed, so the same
/// transaction always produces identical figures regardless of how many times
/// the detail screen is rebuilt. This is *not* a cryptographic generator; it
/// only provides stable variation across transactions.
class SeededRng {
  int _state;

  SeededRng(int seed) : _state = seed & 0xFFFFFFFF;

  /// Returns the next value in the range [0, 1).
  double next() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var z = _state;
    z = ((z ^ (z >>> 15)) * (z | 1)) & 0xFFFFFFFF;
    z = (z + ((((z ^ (z >>> 7)) * (z | 61)) & 0xFFFFFFFF) ^ z)) & 0xFFFFFFFF;
    return ((z ^ (z >>> 14)) & 0xFFFFFFFF) / 4294967296;
  }
}

/// Rounds [value] to two decimal places (whole cents).
double roundToCents(double value) => (value * 100).round() / 100;

/// A single fee line shown in the fee breakdown section.
class FeeLine {
  final String label;
  final double amount;

  const FeeLine(this.label, this.amount);
}

/// A single tax line shown in the tax breakdown section.
class TaxLine {
  final String label;
  final double amount;

  const TaxLine(this.label, this.amount);
}

/// Cross-border settlement details, present only for foreign transactions.
class FxInfo {
  /// ISO 4217 code of the merchant's billing currency.
  final String currency;

  /// Gross amount expressed in [currency].
  final double foreignAmount;

  /// Applied exchange rate (foreign units per USD).
  final double rate;

  /// Embedded currency conversion margin in account currency.
  final double margin;

  const FxInfo(this.currency, this.foreignAmount, this.rate, this.margin);
}

/// The fully resolved monetary breakdown of a transaction.
///
/// The components always reconcile exactly:
///   [net] + [taxTotal] + [feeTotal] = [gross].
class Breakdown {
  final TxCategory category;
  final double gross;
  final double net;
  final List<FeeLine> fees;
  final List<TaxLine> taxes;
  final FxInfo? fx;

  const Breakdown({
    required this.category,
    required this.gross,
    required this.net,
    required this.fees,
    required this.taxes,
    this.fx,
  });

  double get feeTotal => fees.fold(0, (sum, line) => sum + line.amount);

  double get taxTotal => taxes.fold(0, (sum, line) => sum + line.amount);
}

/// Calculates fee and tax components from the category and settlement
/// attributes. Pure logic with no widget or asynchronous dependency.
class BreakdownCalculator {
  const BreakdownCalculator();

  /// Illustrative indirect tax (VAT/GST/sales tax) rates by category.
  ///
  /// These are plausible, not jurisdiction-specific. Essentials and financial,
  /// health and government services are exempt or zero-rated; standard-rated
  /// goods and services use 20%; reduced-rate essentials use 5%.
  static const Map<TxCategory, double> _taxRates = {
    TxCategory.groceries: 0.05,
    TxCategory.dining: 0.20,
    TxCategory.transport: 0.05,
    TxCategory.fuel: 0.20,
    TxCategory.shopping: 0.20,
    TxCategory.digitalGoods: 0.20,
    TxCategory.subscription: 0.20,
    TxCategory.utilities: 0.05,
    TxCategory.travel: 0.10,
    TxCategory.healthcare: 0,
    TxCategory.entertainment: 0.20,
    TxCategory.p2pTransfer: 0,
    TxCategory.professionalServices: 0.20,
    TxCategory.government: 0,
  };

  /// Illustrative exchange rates (foreign units per USD).
  static const List<MapEntry<String, double>> _currencies = [
    MapEntry('EUR', 0.92),
    MapEntry('GBP', 0.79),
    MapEntry('JPY', 149.5),
    MapEntry('CNY', 7.24),
    MapEntry('AUD', 1.52),
    MapEntry('CAD', 1.36),
    MapEntry('CHF', 0.88),
  ];

  /// Builds the [Breakdown] for [tx]. The canonical [category] is supplied by
  /// the caller, which has already run the [CategoryResolver].
  Breakdown calculate(Transaction tx, TxCategory category) {
    final gross = tx.amount;
    final rng = SeededRng(tx.stableSeed.hashCode);

    // ── Fees the customer actually pays, included in the gross amount ──────
    final fees = <FeeLine>[];
    if (tx.crossBorder) {
      fees.add(
        FeeLine('Cross-border acquirer fee', roundToCents(gross * 0.010)),
      );
      fees.add(
        FeeLine('Currency conversion margin', roundToCents(gross * 0.008)),
      );
    }
    if (category == TxCategory.p2pTransfer) {
      fees.add(
        FeeLine(
          'Payment network fee',
          roundToCents(gross * 0.005 < 0.30 ? 0.30 : gross * 0.005),
        ),
      );
    }
    final feeTotal = roundToCents(
      fees.fold(0, (sum, line) => sum + line.amount),
    );

    // ── Indirect tax, tax-inclusive within the remaining amount ────────────
    final taxes = <TaxLine>[];
    final rate = _taxRates[category] ?? 0;
    final afterFees = gross - feeTotal;
    var net = afterFees;
    if (rate > 0) {
      final tax = roundToCents(afterFees * rate / (1 + rate));
      final percent = (rate * 100).toStringAsFixed(0);
      taxes.add(TaxLine('VAT/GST at $percent%', tax));
      net = afterFees - tax;
    }

    // Reconcile to the gross exactly, absorbing any rounding on the net line.
    final taxTotal = roundToCents(
      taxes.fold(0, (sum, line) => sum + line.amount),
    );
    net = roundToCents(gross - feeTotal - taxTotal);

    // ── Cross-border settlement information ────────────────────────────────
    FxInfo? fx;
    if (tx.crossBorder) {
      final index = (rng.next() * _currencies.length).floor();
      final currency = _currencies[index % _currencies.length];
      fx = FxInfo(
        currency.key,
        roundToCents(gross * currency.value),
        currency.value,
        roundToCents(gross * 0.008),
      );
    }

    return Breakdown(
      category: category,
      gross: gross,
      net: net,
      fees: List.unmodifiable(fees),
      taxes: List.unmodifiable(taxes),
      fx: fx,
    );
  }
}
