// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/chart_data.dart';
import 'chart_types.dart';

/// Ranking card: switch between income and expense and the period, showing
/// the rank, amount and a share progress bar.
class RankingCard extends StatefulWidget {
  const RankingCard({super.key});

  @override
  State<RankingCard> createState() => _RankingCardState();
}

class _RankingCardState extends State<RankingCard> {
  ChartFlow _flow = ChartFlow.expense;
  String _period = 'This month';

  final List<String> _periods = ['This week', 'This month', 'This year'];

  /// Formats an integer amount with thousands separators.
  String _money(double value) {
    final grouped = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+$)'),
      (match) => '${match[1]},',
    );
    return '\$$grouped';
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _flow == ChartFlow.income;
    final List<RankItem> list = isIncome
        ? walletRepository.incomeRanking()
        : walletRepository.expenseRanking();
    final total = list.fold<double>(0, (sum, item) => sum + item.amount);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Ranking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              _flowToggle(),
            ],
          ),
          const SizedBox(height: 6),
          _periodDropdown(),
          const SizedBox(height: 8),
          ...List.generate(list.length, (index) {
            final item = list[index];
            final share = (item.amount / total).clamp(0.0, 1.0);
            return _rankRow(index + 1, item, share);
          }),
        ],
      ),
    );
  }

  /// Income/expense toggle.
  Widget _flowToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _toggleButton('Expense', ChartFlow.expense),
          _toggleButton('Income', ChartFlow.income),
        ],
      ),
    );
  }

  Widget _toggleButton(String label, ChartFlow value) {
    final active = _flow == value;
    return GestureDetector(
      onTap: () => setState(() => _flow = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Period dropdown.
  Widget _periodDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _period,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          items: _periods
              .map(
                (period) => DropdownMenuItem<String>(
                  value: period,
                  child: Text(period),
                ),
              )
              .toList(),
          onChanged: (value) => setState(() => _period = value!),
        ),
      ),
    );
  }

  /// A single ranking row.
  Widget _rankRow(int rank, RankItem item, double share) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 18,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 16, color: AppColors.textMuted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _money(item.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 5,
              backgroundColor: const Color(0xFFF3F3F3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
