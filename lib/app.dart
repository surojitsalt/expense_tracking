import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart';
import 'features/income/presentation/income_bloc.dart';
import 'features/expense/presentation/expense_bloc.dart';
import 'features/savings/presentation/savings_bloc.dart';
import 'features/reports/bloc/report_bloc.dart';
import 'features/settings/presentation/settings_bloc.dart';

import 'features/income/presentation/income_source.dart';
import 'features/expense/presentation/expense_details.dart';
import 'features/savings/presentation/savings_details.dart';
import 'features/reports/presentation/report.dart';
import 'features/reports/presentation/piechart.dart';
import 'features/settings/presentation/settings_screen.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(create: (_) => sl<SettingsBloc>()),
        BlocProvider<IncomeBloc>(create: (_) => sl<IncomeBloc>()),
        BlocProvider<ExpenseBloc>(create: (_) => sl<ExpenseBloc>()),
        BlocProvider<SavingsBloc>(create: (_) => sl<SavingsBloc>()),
        BlocProvider<ReportBloc>(create: (_) => sl<ReportBloc>()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: AppTheme.lightTheme,
        initialRoute: '/income',
        routes: {
          '/income': (context) => const IncomeSourceScreen(),
          '/expense': (context) => const ExpenseDetailsScreen(),
          '/savings': (context) => const SavingsDetailsScreen(),
          '/reports': (context) => const ReportScreen(),
          '/chart': (context) => const PieChartScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
