// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'mcc_table.dart';
import 'tx_category.dart';

/// Describes which signal produced a resolved category, in priority order.
///
/// Storing the source (and confidence) makes every classification auditable
/// and allows transactions to be re-classified when the rules are updated.
enum CategorySource {
  /// Resolved from the network MCC carried by the clearing record.
  mcc('Merchant Category Code'),

  /// Resolved from a known merchant in the merchant directory.
  merchantDirectory('Merchant directory'),

  /// Resolved from a versioned merchant-name keyword rule.
  nameRule('Name keyword rule'),

  /// Resolved from the legacy mock-data category (seeded demo entries).
  legacy('Legacy category'),

  /// No signal was sufficient; the transaction awaits manual classification.
  none('Unclassified');

  const CategorySource(this.label);

  /// British-English description of the source.
  final String label;
}

/// The outcome of classification.
class CategoryResolution {
  /// Canonical category that was selected.
  final TxCategory category;

  /// Signal that produced [category].
  final CategorySource source;

  /// Confidence in the result, from 0 (unknown) to 1 (certain).
  final double confidence;

  const CategoryResolution(this.category, this.source, this.confidence);

  /// Whether the result is too weak to rely on and should be confirmed.
  bool get isUncertain => confidence < 0.5;
}

/// Deterministic, layered classifier.
///
/// Signals are consulted in a fixed priority order and the first strong match
/// wins:
///   1. MCC (network-assigned, most reliable)
///   2. Merchant directory (a known counterparty)
///   3. Merchant-name keyword rules (only when the MCC is missing)
///   4. Legacy category (seeded demo data)
///   5. Uncategorised (never a hard guess)
///
/// A machine-learning classifier could be slotted in between steps 3 and 4,
/// returning a category plus confidence and falling through below a threshold.
class CategoryResolver {
  const CategoryResolver();

  /// Versioned merchant-name keyword rules, applied only when no MCC exists.
  /// Each rule maps a lower-case substring to a category.
  static const List<MapEntry<String, TxCategory>> keywordRules = [
    MapEntry('steam', TxCategory.digitalGoods),
    MapEntry('epic games', TxCategory.digitalGoods),
    MapEntry('playstation', TxCategory.digitalGoods),
    MapEntry('xbox', TxCategory.digitalGoods),
    MapEntry('nintendo', TxCategory.digitalGoods),
    MapEntry('game', TxCategory.digitalGoods),
    MapEntry('uber', TxCategory.transport),
    MapEntry('lyft', TxCategory.transport),
    MapEntry('taxi', TxCategory.transport),
    MapEntry('metro', TxCategory.transport),
    MapEntry('train', TxCategory.transport),
    MapEntry('bus', TxCategory.transport),
    MapEntry('petrol', TxCategory.fuel),
    MapEntry('fuel', TxCategory.fuel),
    MapEntry('gas station', TxCategory.fuel),
    MapEntry('tesco', TxCategory.groceries),
    MapEntry('walmart', TxCategory.groceries),
    MapEntry('carrefour', TxCategory.groceries),
    MapEntry('aldi', TxCategory.groceries),
    MapEntry('lidl', TxCategory.groceries),
    MapEntry('grocery', TxCategory.groceries),
    MapEntry('supermarket', TxCategory.groceries),
    MapEntry('restaurant', TxCategory.dining),
    MapEntry('cafe', TxCategory.dining),
    MapEntry('coffee', TxCategory.dining),
    MapEntry('pizza', TxCategory.dining),
    MapEntry('burger', TxCategory.dining),
    MapEntry('kitchen', TxCategory.dining),
    MapEntry('amazon', TxCategory.shopping),
    MapEntry('shop', TxCategory.shopping),
    MapEntry('store', TxCategory.shopping),
    MapEntry('mall', TxCategory.shopping),
    MapEntry('nike', TxCategory.shopping),
    MapEntry('netflix', TxCategory.subscription),
    MapEntry('spotify', TxCategory.subscription),
    MapEntry('disney+', TxCategory.subscription),
    MapEntry('subscription', TxCategory.subscription),
    MapEntry('broadband', TxCategory.utilities),
    MapEntry('utility', TxCategory.utilities),
    MapEntry('electric', TxCategory.utilities),
    MapEntry('hotel', TxCategory.travel),
    MapEntry('flight', TxCategory.travel),
    MapEntry('airways', TxCategory.travel),
    MapEntry('airline', TxCategory.travel),
    MapEntry('booking', TxCategory.travel),
    MapEntry('travel', TxCategory.travel),
    MapEntry('pharmacy', TxCategory.healthcare),
    MapEntry('clinic', TxCategory.healthcare),
    MapEntry('hospital', TxCategory.healthcare),
    MapEntry('dental', TxCategory.healthcare),
    MapEntry('cinema', TxCategory.entertainment),
    MapEntry('movie', TxCategory.entertainment),
    MapEntry('theatre', TxCategory.entertainment),
    MapEntry('concert', TxCategory.entertainment),
    MapEntry('arcade', TxCategory.entertainment),
    MapEntry('casino', TxCategory.entertainment),
    MapEntry('paypal', TxCategory.p2pTransfer),
    MapEntry('wise', TxCategory.p2pTransfer),
    MapEntry('remit', TxCategory.p2pTransfer),
    MapEntry('transfer', TxCategory.p2pTransfer),
    MapEntry('council tax', TxCategory.government),
    MapEntry('tax payment', TxCategory.government),
    MapEntry('government', TxCategory.government),
    MapEntry('fine', TxCategory.government),
    MapEntry('legal', TxCategory.professionalServices),
    MapEntry('accounting', TxCategory.professionalServices),
    MapEntry('consulting', TxCategory.professionalServices),
    MapEntry('course', TxCategory.professionalServices),
    MapEntry('education', TxCategory.professionalServices),
  ];

  /// Resolves the category from the available signals.
  ///
  /// At least one of [mcc], [merchantName] or [legacyCategory] should be
  /// provided; otherwise the result is [TxCategory.uncategorised].
  CategoryResolution resolve({
    String? mcc,
    String? merchantName,
    String? legacyCategory,
    String? title,
  }) {
    // 1. MCC — authoritative.
    final mccCategory = MccTable.categoryFor(mcc);
    if (mccCategory != null) {
      return CategoryResolution(mccCategory, CategorySource.mcc, 0.99);
    }

    // 2. Merchant directory would be consulted here; there is no embedded
    //    directory yet, so it is intentionally skipped.

    // 3. Name keyword rules (only without an MCC).
    if (merchantName != null && merchantName.trim().isNotEmpty) {
      final lower = merchantName.toLowerCase();
      for (final rule in keywordRules) {
        if (lower.contains(rule.key)) {
          return CategoryResolution(rule.value, CategorySource.nameRule, 0.6);
        }
      }
    }

    // 4. Legacy category from the seeded demo data.
    if (legacyCategory != null && legacyCategory.isNotEmpty) {
      return CategoryResolution(
        TxCategory.fromLegacy(legacyCategory, title: title),
        CategorySource.legacy,
        0.8,
      );
    }

    // 5. Never hard-guess.
    return const CategoryResolution(
      TxCategory.uncategorised,
      CategorySource.none,
      0,
    );
  }
}
