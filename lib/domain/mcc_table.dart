// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'tx_category.dart';

/// A single Merchant Category Code entry.
///
/// The MCC is a four-digit number assigned by the card networks to a merchant
/// at onboarding and carried in the authorisation and clearing messages. It is
/// the most reliable indicator of what a transaction was for, so the resolver
/// consults it before anything else.
class MccEntry {
  /// Four-digit MCC, kept as a string to preserve leading zeros.
  final String code;

  /// Official network description.
  final String description;

  /// Canonical category the MCC maps to.
  final TxCategory category;

  const MccEntry(this.code, this.description, this.category);
}

/// Embedded MCC directory.
///
/// This is a curated snapshot, not an exhaustive network list. It covers the
/// codes most relevant to a retail banking aggregator. Ranges (airlines,
/// lodging) are handled separately by [MccTable.categoryFor]. A future Rust
/// authority can ship updated rows; clients keep this copy for offline use.
class MccTable {
  MccTable._();

  /// Schema/snapshot version, bumped whenever the embedded rows change.
  static const int version = 1;

  /// Exact MCC mappings.
  static const List<MccEntry> entries = [
    // Food and groceries.
    MccEntry('5411', 'Grocery stores and supermarkets', TxCategory.groceries),
    MccEntry('5499', 'Convenience stores and specialty food', TxCategory.groceries),
    MccEntry('5811', 'Caterers', TxCategory.dining),
    MccEntry('5812', 'Eating places and restaurants', TxCategory.dining),
    MccEntry('5813', 'Drinking places (alcoholic beverages)', TxCategory.dining),
    MccEntry('5814', 'Fast food restaurants', TxCategory.dining),

    // Transport and fuel.
    MccEntry('4111', 'Local and suburban commuter transport', TxCategory.transport),
    MccEntry('4112', 'Passenger railways', TxCategory.transport),
    MccEntry('4121', 'Taxicabs and limousines', TxCategory.transport),
    MccEntry('4131', 'Bus lines', TxCategory.transport),
    MccEntry('4784', 'Road and bridge tolls', TxCategory.transport),
    MccEntry('7523', 'Parking lots and garages', TxCategory.transport),
    MccEntry('7531', 'Automotive repair and body shops', TxCategory.transport),
    MccEntry('5541', 'Service stations (with or without ancillary services)', TxCategory.fuel),
    MccEntry('5542', 'Automated fuel dispensers', TxCategory.fuel),

    // Retail.
    MccEntry('5300', 'Wholesale clubs and catalogue merchants', TxCategory.shopping),
    MccEntry('5311', 'Department stores', TxCategory.shopping),
    MccEntry('5651', 'Family clothing stores', TxCategory.shopping),
    MccEntry('5691', "Men's and women's clothing stores", TxCategory.shopping),
    MccEntry('5941', 'Sporting goods stores', TxCategory.shopping),
    MccEntry('5942', 'Book stores', TxCategory.shopping),
    MccEntry('5947', 'Gift, card, novelty and souvenir shops', TxCategory.shopping),
    MccEntry('5977', 'Cosmetics and beauty shops', TxCategory.shopping),
    MccEntry('5999', 'Miscellaneous and specialty retail stores', TxCategory.shopping),
    MccEntry('5933', 'Pawn shops and second-hand stores', TxCategory.shopping),

    // Digital goods, software and subscriptions.
    MccEntry('5734', 'Computer software stores', TxCategory.digitalGoods),
    MccEntry('5815', 'Digital goods: media, books, films and music', TxCategory.digitalGoods),
    MccEntry('5816', 'Digital goods: games and in-game content', TxCategory.digitalGoods),
    MccEntry('5817', 'Digital goods: applications and software', TxCategory.digitalGoods),
    MccEntry('5818', 'Digital goods: large digital good purchases', TxCategory.digitalGoods),
    MccEntry('5968', 'Direct marketing: subscription merchants', TxCategory.subscription),
    MccEntry('4899', 'Cable, satellite and streaming television', TxCategory.subscription),
    MccEntry('7372', 'Computer programming and software services', TxCategory.subscription),

    // Utilities and telecommunications.
    MccEntry('4812', 'Telecommunication equipment', TxCategory.utilities),
    MccEntry('4814', 'Telecommunication services', TxCategory.utilities),
    MccEntry('4900', 'Electric, gas, water and sanitary utilities', TxCategory.utilities),

    // Travel.
    MccEntry('4722', 'Travel agencies and tour operators', TxCategory.travel),
    MccEntry('7011', 'Lodging: hotels, motels and resorts', TxCategory.travel),
    MccEntry('7512', 'Car and vehicle rental', TxCategory.travel),

    // Health.
    MccEntry('5912', 'Drug stores and pharmacies', TxCategory.healthcare),
    MccEntry('8011', 'Doctors and physicians', TxCategory.healthcare),
    MccEntry('8021', 'Dentists and orthodontists', TxCategory.healthcare),
    MccEntry('8062', 'Hospitals', TxCategory.healthcare),

    // Leisure.
    MccEntry('7832', 'Motion picture theatres', TxCategory.entertainment),
    MccEntry('7841', 'Video tape and game rental stores', TxCategory.entertainment),
    MccEntry('7922', 'Theatre tickets and productions', TxCategory.entertainment),
    MccEntry('7991', 'Tourist attractions and exhibits', TxCategory.entertainment),
    MccEntry('7994', 'Video game arcades', TxCategory.entertainment),
    MccEntry('7995', 'Gambling and betting', TxCategory.entertainment),
    MccEntry('7997', 'Membership clubs (sports, recreation)', TxCategory.entertainment),

    // Personal and professional services.
    MccEntry('7230', 'Barber and beauty shops', TxCategory.shopping),
    MccEntry('8111', 'Legal services and attorneys', TxCategory.professionalServices),
    MccEntry('8211', 'Schools and educational services', TxCategory.professionalServices),

    // Government and public services.
    MccEntry('9222', 'Fines and government payments', TxCategory.government),
    MccEntry('9311', 'Tax payments', TxCategory.government),

    // Financial, transfers and investments.
    MccEntry('4829', 'Wire transfers and money orders', TxCategory.p2pTransfer),
    MccEntry('6011', 'Financial institutions: cash disbursement', TxCategory.p2pTransfer),
    MccEntry('6012', 'Financial institutions: merchandise and services', TxCategory.p2pTransfer),
    MccEntry('6051', 'Quasi-cash and digital assets', TxCategory.p2pTransfer),
    MccEntry('6529', 'Remote stored-value fund loads', TxCategory.p2pTransfer),
    MccEntry('6537', 'Person-to-person money transfer', TxCategory.p2pTransfer),
    MccEntry('6211', 'Security brokers, dealers and trading', TxCategory.investment),
    MccEntry('6538', 'Prepaid card load and reload', TxCategory.topUp),
  ];

  /// Resolves a numeric [mcc] to its category, including the network ranges
  /// that are not enumerated individually (airlines 3000–3350, lodging
  /// 3501–3999). Returns `null` when the code is absent or unrecognised so the
  /// resolver can move on to the next signal.
  static TxCategory? categoryFor(String? mcc) {
    if (mcc == null || mcc.isEmpty) return null;
    for (final entry in entries) {
      if (entry.code == mcc) return entry.category;
    }
    final value = int.tryParse(mcc);
    if (value != null) {
      if (value >= 3000 && value <= 3350) return TxCategory.travel; // Airlines.
      if (value >= 3501 && value <= 3999) return TxCategory.travel; // Lodging.
    }
    return null;
  }

  /// Returns the network description for [mcc], or `null` if it is not in the
  /// embedded directory.
  static String? descriptionFor(String? mcc) {
    if (mcc == null) return null;
    for (final entry in entries) {
      if (entry.code == mcc) return entry.description;
    }
    return null;
  }
}
