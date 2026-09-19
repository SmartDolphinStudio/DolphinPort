// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Canonical, hierarchical transaction taxonomy.
///
/// This is the single source of truth for *what kind* of transaction something
/// is. It is deliberately independent of any widget so it can be unit tested,
/// serialised and later mirrored by the Rust authority service. Each value has
/// a stable [code] that never changes once published; the [label] is the
/// human-facing, British-English name.
///
/// New categories must be appended and never re-ordered or removed, because
/// the codes are persisted with historical transactions.
enum TxCategory {
  // ── Incoming ────────────────────────────────────────────────────────────
  salary('salary', 'Salary', Icons.business_center_outlined, true),
  topUp('top_up', 'Top up', Icons.add, true),
  refund('refund', 'Refund', Icons.undo_rounded, true),
  investment('investment', 'Investment', Icons.trending_up_rounded, true),

  // ── Outgoing ────────────────────────────────────────────────────────────
  groceries('groceries', 'Groceries', Icons.local_grocery_store_outlined, false),
  dining('dining', 'Dining', Icons.restaurant_outlined, false),
  transport('transport', 'Transport', Icons.directions_bus_outlined, false),
  fuel('fuel', 'Fuel', Icons.local_gas_station_outlined, false),
  shopping('shopping', 'Shopping', Icons.shopping_bag_outlined, false),
  digitalGoods('digital_goods', 'Digital goods', Icons.sports_esports_outlined, false),
  subscription('subscription', 'Subscription', Icons.subscriptions_outlined, false),
  utilities('utilities', 'Utilities', Icons.receipt_long_outlined, false),
  travel('travel', 'Travel', Icons.flight_takeoff_outlined, false),
  healthcare('healthcare', 'Healthcare', Icons.local_hospital_outlined, false),
  entertainment('entertainment', 'Entertainment', Icons.confirmation_number_outlined, false),
  p2pTransfer('p2p_transfer', 'Peer-to-peer transfer', Icons.swap_horiz, false),
  professionalServices(
    'professional_services',
    'Professional services',
    Icons.handyman_outlined,
    false,
  ),
  government('government', 'Government', Icons.account_balance_outlined, false),
  uncategorised('uncategorised', 'Uncategorised', Icons.help_outline, false);

  const TxCategory(this.code, this.label, this.icon, this.isIncome);

  /// Stable identifier persisted with the transaction.
  final String code;

  /// British-English display name.
  final String label;

  /// Default icon used in lists and detail headers.
  final IconData icon;

  /// Whether the category represents money coming in rather than leaving.
  final bool isIncome;

  /// Looks up a category by its stable [code], falling back to
  /// [TxCategory.uncategorised] for unknown or missing values.
  static TxCategory byCode(String? code) {
    for (final category in values) {
      if (category.code == code) return category;
    }
    return TxCategory.uncategorised;
  }

  /// Maps the legacy free-text category strings used by the original mock
  /// data set onto the canonical taxonomy.
  ///
  /// The old 'Income' bucket is ambiguous, so the transaction [title] is used
  /// to distinguish a salary from a top-up, investment or refund.
  static TxCategory fromLegacy(String? legacy, {String? title}) {
    switch (legacy) {
      case 'Food':
        return TxCategory.dining;
      case 'Transport':
        return TxCategory.transport;
      case 'Shopping':
        return TxCategory.shopping;
      case 'Bills':
        return TxCategory.utilities;
      case 'Entertainment':
        return TxCategory.entertainment;
      case 'Transfer':
        return TxCategory.p2pTransfer;
      case 'Income':
        final lower = title?.toLowerCase() ?? '';
        if (lower.contains('salary')) return TxCategory.salary;
        if (lower.contains('top')) return TxCategory.topUp;
        if (lower.contains('invest')) return TxCategory.investment;
        if (lower.contains('refund')) return TxCategory.refund;
        return TxCategory.salary;
      default:
        return TxCategory.uncategorised;
    }
  }
}
