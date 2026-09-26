// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/chart_data.dart';
import 'chart_types.dart';

/// Monthly income or expense line chart, with a curved line and gradient fill.
class LineChartView extends StatelessWidget {
  final ChartFlow flow;
  final String Function(double) formatMoney;

  const LineChartView({
    super.key,
    required this.flow,
    required this.formatMoney,
  });

  bool get _isIncome => flow == ChartFlow.income;

  double _value(MonthPoint month) => _isIncome ? month.income : month.expense;

  @override
  Widget build(BuildContext context) {
    final series = walletRepository.monthlySeries();
    final spots = List.generate(
      series.length,
      (index) => FlSpot(index.toDouble(), _value(series[index])),
    );
    final maxValue = series.map(_value).reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxValue * 1.2,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black,
            getTooltipItems: (touchedSpots) => touchedSpots
                .map(
                  (spot) => LineTooltipItem(
                    formatMoney(spot.y),
                    const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                )
                .toList(),
          ),
        ),
        titlesData: FlTitlesData(
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
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            color: Colors.black,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
