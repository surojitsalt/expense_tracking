import 'package:flutter/material.dart';

class ExpenseTrackerAppColors extends ThemeExtension<ExpenseTrackerAppColors> {
  final Color income;
  final Color expense;
  final Color savings;
  final Color incomeLight;
  final Color expenseLight;
  final Color savingsLight;

  const ExpenseTrackerAppColors({
    required this.income,
    required this.expense,
    required this.savings,
    required this.incomeLight,
    required this.expenseLight,
    required this.savingsLight,
  });

  @override
  ThemeExtension<ExpenseTrackerAppColors> copyWith({
    Color? income,
    Color? expense,
    Color? savings,
    Color? incomeLight,
    Color? expenseLight,
    Color? savingsLight,
  }) {
    return ExpenseTrackerAppColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      savings: savings ?? this.savings,
      incomeLight: incomeLight ?? this.incomeLight,
      expenseLight: expenseLight ?? this.expenseLight,
      savingsLight: savingsLight ?? this.savingsLight,
    );
  }

  @override
  ThemeExtension<ExpenseTrackerAppColors> lerp(
      covariant ThemeExtension<ExpenseTrackerAppColors>? other, double t) {
    if (other is! ExpenseTrackerAppColors) {
      return this;
    }
    return ExpenseTrackerAppColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      incomeLight: Color.lerp(incomeLight, other.incomeLight, t)!,
      expenseLight: Color.lerp(expenseLight, other.expenseLight, t)!,
      savingsLight: Color.lerp(savingsLight, other.savingsLight, t)!,
    );
  }
}
