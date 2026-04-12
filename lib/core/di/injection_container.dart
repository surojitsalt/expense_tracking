import 'package:get_it/get_it.dart';

import '../database/database_helper.dart';

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

// Reports
import '../../features/reports/bloc/report_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database Helper
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper.instance);

  // Repositories
  sl.registerLazySingleton<IncomeRepository>(() => IncomeRepositoryImpl(db: sl()));
  sl.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl(db: sl()));
  sl.registerLazySingleton<SavingsRepository>(() => SavingsRepositoryImpl(db: sl()));
  
  // UseCases
  sl.registerLazySingleton(() => IncomeUseCase(sl()));
  sl.registerLazySingleton(() => ExpenseUseCase(sl()));
  sl.registerLazySingleton(() => SavingsUseCase(sl()));

  // BLoCs
  sl.registerFactory(() => IncomeBloc(incomeUseCase: sl()));
  sl.registerFactory(() => ExpenseBloc(expenseUseCase: sl()));
  sl.registerFactory(() => SavingsBloc(savingsUseCase: sl()));
  sl.registerFactory(() => ReportBloc(
        incomeUseCase: sl(),
        expenseUseCase: sl(),
        savingsUseCase: sl(),
      ));
}
