import 'package:get_it/get_it.dart';

import '../database/database_helper.dart';

// Settings
import '../../features/settings/data/settings_service.dart';
import '../../features/settings/presentation/settings_bloc.dart';

// Income
import '../../features/income/domain/income_repository.dart';
import '../../features/income/data/income_repository_impl.dart';
import '../../features/income/domain/income_usecase.dart';
import '../../features/income/presentation/income_bloc.dart';

// Expense
import '../../features/expense/domain/expense_repository.dart';
import '../../features/expense/data/expense_repository_impl.dart';
import '../../features/expense/domain/expense_usecase.dart';
import '../../features/expense/presentation/expense_bloc.dart';

// Savings
import '../../features/savings/domain/savings_repository.dart';
import '../../features/savings/data/savings_repository_impl.dart';
import '../../features/savings/domain/savings_usecase.dart';
import '../../features/savings/presentation/savings_bloc.dart';
import '../../features/savings/domain/savings_withdrawal_repository.dart';
import '../../features/savings/data/savings_withdrawal_repository_impl.dart';
import '../../features/savings/domain/savings_withdrawal_usecase.dart';

// Reports
import '../../features/reports/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Settings
  sl.registerLazySingleton<SettingsService>(() => SettingsService());
  sl.registerFactory(() => SettingsBloc(settingsService: sl())..add(const LoadSettings()));

  // Database Helper
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Repositories
  sl.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl(db: sl()));
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(db: sl()));
  sl.registerLazySingleton<SavingsRepository>(() => SavingsRepositoryImpl(db: sl()));
  sl.registerLazySingleton<SavingsWithdrawalRepository>(() => SavingsWithdrawalRepositoryImpl(db: sl()));

  // UseCases
  sl.registerLazySingleton(() => IncomeUseCase(sl()));
  sl.registerLazySingleton(() => ExpenseUseCase(sl()));
  sl.registerLazySingleton(() => SavingsUseCase(sl()));
  sl.registerLazySingleton(() => SavingsWithdrawalUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => IncomeBloc(incomeUseCase: sl(), savingsUseCase: sl()));
  sl.registerFactory(() => ExpenseBloc(expenseUseCase: sl()));
  sl.registerFactory(() => SavingsBloc(savingsUseCase: sl()));
  sl.registerFactory(() => ReportBloc(
        incomeUseCase: sl(),
        expenseUseCase: sl(),
        savingsUseCase: sl(),
        withdrawalUseCase: sl(),
      ));
}
