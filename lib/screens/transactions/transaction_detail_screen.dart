// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/detail_plan.dart';
import '../../models/transaction.dart';

/// Transaction detail screen.
///
/// The body is data-driven: a [DetailPlanBuilder] resolves the transaction's
/// category and produces only the sections that apply (for example, cross-border
/// settlement, a fee breakdown or a tax breakdown), so different transaction
/// types render different rows without any per-type screen code.
class TransactionDetailScreen extends StatelessWidget {
  final Transaction tx;

  const TransactionDetailScreen({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final plan = const DetailPlanBuilder().build(tx);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _Header(tx: tx),
          const SizedBox(height: 18),
          for (final section in plan.sections) ...[
            _SectionBlock(section: section),
            const SizedBox(height: 14),
          ],
          const _DeductionBlock(),
          const SizedBox(height: 14),
          const _BillingBlock(),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              'Powered by DolphinPort',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header: icon, counterparty name and the signed amount.
class _Header extends StatelessWidget {
  final Transaction tx;

  const _Header({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(tx.icon, color: AppColors.textMuted, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          tx.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${tx.isIncome ? '+' : '-'}${DetailPlanBuilder.formatUsd(tx.amount)}',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: tx.isIncome ? AppColors.income : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// A titled section rendered as a light card with label/value rows.
class _SectionBlock extends StatelessWidget {
  final DetailSection section;

  const _SectionBlock({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            section.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            children: [
              for (var i = 0; i < section.rows.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppColors.divider),
                _RowView(row: section.rows[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single label/value row.
class _RowView extends StatelessWidget {
  final DetailRow row;

  const _RowView({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              row.label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              row.value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: row.strong ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Deduction method and priority group, kept as a fixed aggregator feature.
class _DeductionBlock extends StatelessWidget {
  const _DeductionBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Deduction',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: const Column(
            children: [
              _FixedRow('Deduction method', 'Visa •• 4242'),
              Divider(height: 1, color: AppColors.divider),
              _FixedRow('Deduction priority', 'Balance · Visa · Mastercard'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Billing services group with three entries.
class _BillingBlock extends StatelessWidget {
  const _BillingBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Billing services',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: const Column(
            children: [
              _ServiceRow(Icons.receipt_outlined, 'Billing information'),
              Divider(height: 1, indent: 46, color: AppColors.divider),
              _ServiceRow(Icons.description_outlined, 'Terms and conditions'),
              Divider(height: 1, indent: 46, color: AppColors.divider),
              _ServiceRow(Icons.privacy_tip_outlined, 'Privacy policy'),
            ],
          ),
        ),
      ],
    );
  }
}

/// A non-conditional label/value row.
class _FixedRow extends StatelessWidget {
  final String label;
  final String value;

  const _FixedRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable billing service entry.
class _ServiceRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label is not part of the demo.'),
          duration: const Duration(seconds: 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
