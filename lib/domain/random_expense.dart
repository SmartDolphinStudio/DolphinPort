// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import '../core/clock.dart';
import '../models/transaction.dart';
import 'tx_breakdown.dart';
import 'tx_category.dart';

/// A merchant that a scanned payment can be settled with.
class Merchant {
  final String name;
  final String mcc;

  const Merchant(this.name, this.mcc);
}

/// Creates a fully random, always-outgoing transaction that simulates the
/// result of scanning a payment code.
///
/// The category, merchant and amount are random, but the direction is fixed:
/// every result is an expense. The per-transaction fee and tax rows are later
/// derived deterministically from the transaction id, so they stay stable.
class RandomExpenseGenerator {
  /// Weighted expense categories; weights bias the mix towards everyday spend.
  static const List<MapEntry<TxCategory, int>> _weights = [
    MapEntry(TxCategory.dining, 16),
    MapEntry(TxCategory.groceries, 14),
    MapEntry(TxCategory.shopping, 16),
    MapEntry(TxCategory.transport, 10),
    MapEntry(TxCategory.digitalGoods, 10),
    MapEntry(TxCategory.fuel, 8),
    MapEntry(TxCategory.subscription, 7),
    MapEntry(TxCategory.entertainment, 7),
    MapEntry(TxCategory.travel, 7),
    MapEntry(TxCategory.utilities, 6),
    MapEntry(TxCategory.p2pTransfer, 5),
    MapEntry(TxCategory.healthcare, 4),
    MapEntry(TxCategory.professionalServices, 3),
  ];

  /// Merchants available per category.
  static const Map<TxCategory, List<Merchant>> _merchants = {
    TxCategory.dining: [
      Merchant('Pret A Manger', '5812'),
      Merchant('Costa Coffee', '5814'),
      Merchant('Wagamama', '5812'),
      Merchant("Nando's", '5812'),
      Merchant('Greggs', '5814'),
      Merchant('Starbucks', '5812'),
      Merchant('Five Guys', '5812'),
    ],
    TxCategory.groceries: [
      Merchant('Tesco', '5411'),
      Merchant("Sainsbury's", '5411'),
      Merchant('Aldi', '5411'),
      Merchant('Lidl', '5411'),
      Merchant('Waitrose', '5411'),
      Merchant('Morrisons', '5411'),
      Merchant('Asda', '5411'),
    ],
    TxCategory.shopping: [
      Merchant('Amazon', '5999'),
      Merchant('Argos', '5311'),
      Merchant('John Lewis', '5311'),
      Merchant('Marks & Spencer', '5651'),
      Merchant('Next', '5651'),
      Merchant('IKEA', '5712'),
      Merchant('Uniqlo', '5651'),
      Merchant('H&M', '5651'),
    ],
    TxCategory.transport: [
      Merchant('Transport for London', '4111'),
      Merchant('National Rail', '4112'),
      Merchant('Uber', '4121'),
      Merchant('Bolt', '4121'),
      Merchant('Arriva', '4131'),
      Merchant('Stagecoach', '4111'),
    ],
    TxCategory.digitalGoods: [
      Merchant('Steam', '5816'),
      Merchant('PlayStation Network', '5816'),
      Merchant('Xbox Store', '5816'),
      Merchant('Nintendo eShop', '5816'),
      Merchant('Epic Games', '5816'),
      Merchant('GOG', '5815'),
      Merchant('Google Play', '5817'),
    ],
    TxCategory.fuel: [
      Merchant('Shell', '5541'),
      Merchant('BP', '5541'),
      Merchant('Esso', '5542'),
      Merchant('Texaco', '5541'),
      Merchant('Gulf', '5541'),
    ],
    TxCategory.subscription: [
      Merchant('Netflix', '4899'),
      Merchant('Spotify', '4899'),
      Merchant('Disney+', '4899'),
      Merchant('YouTube Premium', '4899'),
      Merchant('Adobe', '5734'),
      Merchant('Microsoft 365', '5734'),
      Merchant('Audible', '5968'),
      Merchant('Dropbox', '5734'),
    ],
    TxCategory.entertainment: [
      Merchant('Odeon', '7832'),
      Merchant('Vue Cinemas', '7832'),
      Merchant('Ticketmaster', '7922'),
      Merchant('Cineworld', '7832'),
      Merchant('SEA LIFE', '7991'),
      Merchant('Alton Towers', '7991'),
    ],
    TxCategory.travel: [
      Merchant('British Airways', '4722'),
      Merchant('easyJet', '4722'),
      Merchant('Booking.com', '4722'),
      Merchant('Airbnb', '7011'),
      Merchant('Premier Inn', '7011'),
      Merchant('Expedia', '4722'),
      Merchant('Ryanair', '4722'),
      Merchant('Hilton', '7011'),
    ],
    TxCategory.utilities: [
      Merchant('British Gas', '4900'),
      Merchant('EDF Energy', '4900'),
      Merchant('Thames Water', '4900'),
      Merchant('BT Broadband', '4814'),
      Merchant('Sky Mobile', '4814'),
      Merchant('Octopus Energy', '4900'),
    ],
    TxCategory.p2pTransfer: [
      Merchant('PayPal', '6537'),
      Merchant('Wise', '4829'),
      Merchant('Revolut', '6537'),
      Merchant('Remitly', '4829'),
      Merchant('Western Union', '4829'),
    ],
    TxCategory.healthcare: [
      Merchant('Boots Pharmacy', '5912'),
      Merchant('Bupa', '8062'),
      Merchant('NHS Pharmacy', '5912'),
      Merchant('Lloyds Pharmacy', '5912'),
    ],
    TxCategory.professionalServices: [
      Merchant('Deloitte', '7372'),
      Merchant('KPMG', '7372'),
      Merchant('Coursera', '8211'),
      Merchant('Udemy', '8211'),
      Merchant('Solicitors LLP', '8111'),
      Merchant('Accenture', '7372'),
    ],
  };

  /// Probability that a category is settled across a border.
  static const Map<TxCategory, double> _crossBorderChance = {
    TxCategory.travel: 0.6,
    TxCategory.digitalGoods: 0.45,
    TxCategory.subscription: 0.3,
    TxCategory.p2pTransfer: 0.25,
    TxCategory.professionalServices: 0.2,
    TxCategory.shopping: 0.12,
  };

  /// Generates the next random expense.
  Transaction next() {
    final rng = SeededRng(Clock.now().microsecondsSinceEpoch);

    final category = _pickCategory(rng);
    final merchants = _merchants[category]!;
    final merchant =
        merchants[(rng.next() * merchants.length).floor() % merchants.length];
    final amount = _pickAmount(rng);
    final crossChance = _crossBorderChance[category] ?? 0.05;
    final crossBorder = rng.next() < crossChance;
    final now = Clock.now();

    return Transaction(
      title: merchant.name,
      subtitle: 'Just now',
      amount: amount,
      type: TxType.expense,
      category: category.code,
      icon: category.icon,
      timestamp: now,
      id: 'TX${now.microsecondsSinceEpoch}${(rng.next() * 1000).round()}',
      mcc: merchant.mcc,
      currencyCode: 'USD',
      crossBorder: crossBorder,
    );
  }

  /// Selects a category according to the weights.
  TxCategory _pickCategory(SeededRng rng) {
    final total = _weights.fold<int>(0, (sum, e) => sum + e.value);
    var target = (rng.next() * total).floor();
    for (final entry in _weights) {
      target -= entry.value;
      if (target < 0) return entry.key;
    }
    return TxCategory.dining;
  }

  /// Selects an amount from a skewed distribution: mostly small, occasionally
  /// large, never negative.
  double _pickAmount(SeededRng rng) {
    final r = rng.next();
    double value;
    if (r < 0.60) {
      value = 1 + rng.next() * 119; // Small, everyday spend.
    } else if (r < 0.88) {
      value = 120 + rng.next() * 1380; // Medium.
    } else if (r < 0.98) {
      value = 1500 + rng.next() * 18500; // Large.
    } else {
      value = 20000 + rng.next() * 230000; // Rare, very large.
    }
    // Most card amounts are whole; keep cents on a minority for realism.
    return rng.next() < 0.5 ? value.roundToDouble() : roundToCents(value);
  }
}
