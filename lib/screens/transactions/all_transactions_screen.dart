// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/routes.dart';
import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../widgets/transaction_tile.dart';

/// All-transactions screen: a compact range picker, a small summary line and
/// the full transaction list, with access to the analytics screen.
class AllTransactionsScreen extends StatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  State<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends State<AllTransactionsScreen> {
  TransactionRange _range = TransactionRange.thisMonth;
  DateTimeRange? _customRange;

  /// Labels for the range picker, ordered to match [TransactionRange].
  static const List<String> _rangeLabels = [
    'Today',
    'This week',
    'This month',
    'This year',
    'Custom',
  ];

  /// Formats an amount with thousands separators and two decimals.
  String _money(double value) {
    final fixed = value.toStringAsFixed(2);
    final grouped = fixed.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+\.)'),
      (match) => '${match[1]},',
    );
    return '\$$grouped';
  }

  /// Opens the date range picker for the custom option.
  Future<void> _selectCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      helpText: 'Select a range',
    );
    if (!mounted) return;
    if (picked == null) {
      // Revert the dropdown when the picker is dismissed.
      setState(() => _range = TransactionRange.thisMonth);
      return;
    }
    setState(() {
      _customRange = DateTimeRange(
        start: DateTime(
          picked.start.year,
          picked.start.month,
          picked.start.day,
        ),
        end: DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        ),
      );
      _range = TransactionRange.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = walletRepository.transactionsInRange(
      _range,
      custom: _customRange,
    );
    var income = 0.0;
    var expense = 0.0;
    for (final transaction in visible) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Top bar.
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _backButton(),
                    const SizedBox(width: 12),
                    const Text(
                      'Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Compact black range picker, aligned to the left.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _rangePicker(),
                ),
              ),
              const SizedBox(height: 14),
              // Small grey summary line and the charts entry.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Income ${_money(income)}   ·   '
                        'Expense ${_money(expense)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          Navigator.pushNamed(context, RouteNames.analytics),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View charts',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Filtered transaction list.
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      TransactionTile(tx: visible[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Compact black capsule range picker.
  Widget _rangePicker() {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today_rounded,
            color: Colors.white,
            size: 15,
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _range.index,
              isDense: true,
              dropdownColor: const Color(0xFF1A1A1A),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 20,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              items: [
                for (var i = 0; i < _rangeLabels.length; i++)
                  DropdownMenuItem<int>(value: i, child: Text(_rangeLabels[i])),
              ],
              onChanged: (value) {
                if (value == null) return;
                if (value == TransactionRange.custom.index) {
                  _selectCustomRange();
                } else {
                  setState(() => _range = TransactionRange.values[value]);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Back button.
  Widget _backButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
