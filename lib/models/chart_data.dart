// DolphinPort — an Android-only digital wallet front-end for learning and demonstration.
// Copyright (c) 2026 SmartDolphin Studio · Author: Astraeus

import 'package:flutter/material.dart';

/// Monthly income and expense data point for the bar and line charts.
class MonthPoint {
  final String label;
  final double income;
  final double expense;

  const MonthPoint(this.label, this.income, this.expense);
}

/// Category slice for the pie chart.
class CategorySlice {
  final String label;
  final double value;
  final Color color;

  const CategorySlice(this.label, this.value, this.color);
}

/// Entry in an income or expense ranking.
class RankItem {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const RankItem(this.label, this.amount, this.color, this.icon);
}
