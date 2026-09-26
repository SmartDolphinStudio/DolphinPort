// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import 'bar_chart_view.dart';
import 'chart_types.dart';
import 'line_chart_view.dart';
import 'pie_chart_view.dart';
import 'ranking_card.dart';

/// Analytics screen: switch between bar, line and pie charts, filter by year
/// and by income or expense, with ranking lists below.
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  ChartKind _kind = ChartKind.bar;
  ChartFlow _flow = ChartFlow.expense;
  String _year = '2026';

  final List<String> _years = ['2024', '2025', '2026'];

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _topBar(),
              const SizedBox(height: 16),
              _chartCard(),
              const SizedBox(height: 16),
              const RankingCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Top bar: back button, title and chart-type toggle.
  Widget _topBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Analytics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _kindToggle(),
      ],
    );
  }

  /// Three-segment chart-type toggle.
  Widget _kindToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _kindButton(ChartKind.bar, Icons.bar_chart_rounded),
          _kindButton(ChartKind.line, Icons.show_chart_rounded),
          _kindButton(ChartKind.pie, Icons.pie_chart_rounded),
        ],
      ),
    );
  }

  Widget _kindButton(ChartKind kind, IconData icon) {
    final active = _kind == kind;
    return GestureDetector(
      onTap: () => setState(() => _kind = kind),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: active ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  /// Chart card: filter row, total and chart.
  Widget _chartCard() {
    final isIncome = _flow == ChartFlow.income;
    final total = isIncome
        ? walletRepository.totalIncome()
        : walletRepository.totalExpense();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Row(children: [_yearDropdown(), const Spacer(), _flowToggle()]),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isIncome ? 'Total income' : 'Total expense',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _money(total),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 220, child: _buildChart()),
        ],
      ),
    );
  }

  /// Year dropdown.
  Widget _yearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _year,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.textMuted,
          ),
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          items: _years
              .map(
                (year) =>
                    DropdownMenuItem<String>(value: year, child: Text(year)),
              )
              .toList(),
          onChanged: (value) => setState(() => _year = value!),
        ),
      ),
    );
  }

  /// Two-segment income/expense toggle.
  Widget _flowToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _flowButton('Expense', ChartFlow.expense),
          _flowButton('Income', ChartFlow.income),
        ],
      ),
    );
  }

  Widget _flowButton(String label, ChartFlow value) {
    final active = _flow == value;
    return GestureDetector(
      onTap: () => setState(() => _flow = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Builds the chart for the currently selected kind.
  Widget _buildChart() {
    switch (_kind) {
      case ChartKind.bar:
        return BarChartView(flow: _flow, formatMoney: _money);
      case ChartKind.line:
        return LineChartView(flow: _flow, formatMoney: _money);
      case ChartKind.pie:
        return PieChartView(flow: _flow);
    }
  }
}
