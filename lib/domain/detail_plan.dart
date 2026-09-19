// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import '../models/transaction.dart';
import 'category_resolver.dart';
import 'tx_breakdown.dart';

/// A single label/value row inside a detail section.
class DetailRow {
  final String label;
  final String value;

  /// Whether the row is a subtotal rendered with emphasis.
  final bool strong;

  const DetailRow(this.label, this.value, {this.strong = false});
}

/// A titled block of rows. Sections are the conditional "tables": the builder
/// only adds a section when the transaction's attributes warrant it.
class DetailSection {
  final String title;
  final List<DetailRow> rows;

  const DetailSection(this.title, this.rows);
}

/// A transaction resolved into an ordered set of detail sections.
class DetailPlan {
  final CategoryResolution resolution;
  final Breakdown breakdown;
  final List<DetailSection> sections;

  const DetailPlan(this.resolution, this.breakdown, this.sections);
}

/// Assembles a [DetailPlan] from a [Transaction] using the resolver and the
/// field/section registry. This is the data-driven replacement for what used
/// to be a fixed list of hardcoded rows.
class DetailPlanBuilder {
  const DetailPlanBuilder();

  static const CategoryResolver _resolver = CategoryResolver();
  static const BreakdownCalculator _calculator = BreakdownCalculator();

  /// Formats [value] in USD with thousands separators and two decimals.
  static String formatUsd(double value) {
    final sign = value < 0 ? '-' : '';
    final abs = value.abs();
    final cents = abs.toStringAsFixed(2);
    final parts = cents.split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '$sign\$$grouped.${parts[1]}';
  }

  /// Builds the plan for [tx].
  DetailPlan build(Transaction tx) {
    final resolution = _resolver.resolve(
      mcc: tx.mcc,
      merchantName: tx.title,
      legacyCategory: tx.category,
      title: tx.title,
    );
    final breakdown = _calculator.calculate(tx, resolution.category);
    final category = resolution.category;

    final seed = tx.stableSeed.hashCode;
    final txId = tx.id.isNotEmpty
        ? tx.id
        : 'TX${(seed & 0x7FFFFFFF).toString().padLeft(10, '0')}';
    final orderNo = 'MO${((seed >> 5) & 0x7FFFFFFF).toString().padLeft(9, '0')}';

    final date =
        '${tx.timestamp.year}-'
        '${tx.timestamp.month.toString().padLeft(2, '0')}-'
        '${tx.timestamp.day.toString().padLeft(2, '0')} '
        '${_hourLabel(tx.timestamp)}';

    final item = category.isIncome
        ? '${category.label} credit'
        : '${category.label} purchase';

    final confidence = resolution.confidence == 0
        ? '—'
        : '${(resolution.confidence * 100).round()}%';

    final sections = <DetailSection>[
      // ── Core overview, always present ───────────────────────────────────
      DetailSection('Overview', [
        const DetailRow('Status', 'Completed'),
        DetailRow('Date', date),
        DetailRow('Item', item),
        DetailRow('Merchant', tx.title),
        const DetailRow('Acquirer', 'DolphinPort Demo Acquiring Bank'),
        DetailRow('Classification', '${category.label} · ${resolution.source.label}'),
        DetailRow('Confidence', confidence),
        const DetailRow('Payment method', 'Visa •• 4242'),
        DetailRow('Transaction ID', txId),
        DetailRow('Merchant order no.', orderNo),
      ]),
    ];

    // ── Cross-border settlement, only when foreign ────────────────────────
    final fx = breakdown.fx;
    if (fx != null) {
      final decimals = fx.currency == 'JPY' ? 0 : 2;
      sections.add(
        DetailSection('Cross-border settlement', [
          DetailRow('Billing currency', fx.currency),
          DetailRow('Foreign amount', _formatForeign(fx.foreignAmount, decimals, fx.currency)),
          DetailRow('Exchange rate', '1 USD = ${fx.rate} ${fx.currency}'),
          DetailRow('Conversion margin', formatUsd(fx.margin)),
        ]),
      );
    }

    // ── Fee breakdown, only when fees apply ───────────────────────────────
    if (breakdown.fees.isNotEmpty) {
      sections.add(
        DetailSection('Fee breakdown', [
          for (final fee in breakdown.fees)
            DetailRow(fee.label, formatUsd(fee.amount)),
          DetailRow('Total fees', formatUsd(breakdown.feeTotal), strong: true),
        ]),
      );
    }

    // ── Tax breakdown, only when tax applies ──────────────────────────────
    if (breakdown.taxes.isNotEmpty) {
      sections.add(
        DetailSection('Tax breakdown', [
          DetailRow('Net amount (before tax)', formatUsd(breakdown.net)),
          for (final tax in breakdown.taxes)
            DetailRow(tax.label, formatUsd(tax.amount)),
          DetailRow(
            'Amount after tax',
            formatUsd(breakdown.net + breakdown.taxTotal),
            strong: true,
          ),
        ]),
      );
    }

    return DetailPlan(resolution, breakdown, List.unmodifiable(sections));
  }

  /// Formats an hour in 12-hour time, e.g. "2:04pm".
  static String _hourLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute${date.hour < 12 ? 'am' : 'pm'}';
  }

  /// Formats a foreign amount with the appropriate number of decimals.
  static String _formatForeign(double value, int decimals, String currency) {
    final fixed = value.toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    final tail = parts.length > 1 ? '.${parts[1]}' : '';
    return '$grouped$tail $currency';
  }
}
