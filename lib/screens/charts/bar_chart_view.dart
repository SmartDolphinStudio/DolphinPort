// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/chart_data.dart';
import 'chart_types.dart';

/// Monthly income or expense bar chart.
class BarChartView extends StatelessWidget {
  final ChartFlow flow;
  final String Function(double) formatMoney;

  const BarChartView({
    super.key,
    required this.flow,
    required this.formatMoney,
  });

  bool get _isIncome => flow == ChartFlow.income;

  double _value(MonthPoint month) => _isIncome ? month.income : month.expense;

  @override
  Widget build(BuildContext context) {
    final series = walletRepository.monthlySeries();
    final maxValue = series.map(_value).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * 1.25,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black,
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  formatMoney(rod.toY),
                  const TextStyle(color: Colors.white, fontSize: 11),
                ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= series.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    series[index].label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(series.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _value(series[index]),
                color: Colors.black,
                width: 18,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue * 1.25,
                  color: const Color(0xFFF3F3F3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
