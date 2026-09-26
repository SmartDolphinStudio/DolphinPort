// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../app/theme.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/chart_data.dart';
import 'chart_types.dart';

/// Category share pie chart (a ring) with a legend on the right.
class PieChartView extends StatelessWidget {
  final ChartFlow flow;

  const PieChartView({super.key, required this.flow});

  /// Returns the slices for the selected direction.
  List<CategorySlice> get _slices {
    if (flow == ChartFlow.income) {
      return const [
        CategorySlice('Salary', 0.62, Color(0xFF111111)),
        CategorySlice('Top up', 0.29, Color(0xFF6B7280)),
        CategorySlice('Investment', 0.09, Color(0xFFD1D5DB)),
      ];
    }
    return walletRepository.expenseSlices();
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices;

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 38,
              sections: slices.map((slice) {
                return PieChartSectionData(
                  value: slice.value,
                  color: slice.color,
                  title: '${(slice.value * 100).toInt()}%',
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  radius: 48,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Legend.
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: slices.map((slice) {
            final isDark = slice.color.computeLuminance() < 0.4;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: slice.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    slice.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF333333)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
