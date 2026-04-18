import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../income/domain/income_model.dart';
import '../../income/domain/income_usecase.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/domain/expense_usecase.dart';
import '../../savings/domain/savings_model.dart';
import '../../savings/domain/savings_usecase.dart';
import '../../savings/domain/savings_withdrawal_model.dart';
import '../../savings/domain/savings_withdrawal_usecase.dart';

// Events
abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportEvent {}

class FilterReportByDate extends ReportEvent {
  final DateTime start;
  final DateTime end;
  const FilterReportByDate(this.start, this.end);
  @override
  List<Object?> get props => [start, end];
}

class AddSavingsWithdrawal extends ReportEvent {
  final SavingsWithdrawalModel withdrawal;
  const AddSavingsWithdrawal(this.withdrawal);
  @override
  List<Object?> get props => [withdrawal];
}

// States
abstract class ReportState extends Equatable {
  const ReportState();
  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}
class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<IncomeModel> incomes;
  final List<ExpenseModel> expenses;
  final List<SavingsModel> savings;
  final List<SavingsWithdrawalModel> withdrawals;
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;
  final double totalWithdrawals;

  const ReportLoaded({
    required this.incomes,
    required this.expenses,
    required this.savings,
    required this.withdrawals,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
    required this.totalWithdrawals,
  });

  // savings = income - expense (user's formula), then minus withdrawals
  double get netSavings => totalIncome - totalExpense - totalWithdrawals;
  // in-hand cash = withdrawals (money taken out of savings pool)
  double get inHandCash => totalWithdrawals;

  @override
  List<Object?> get props => [
    incomes, expenses, savings, withdrawals,
    totalIncome, totalExpense, totalSavings, totalWithdrawals,
  ];
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final IncomeUseCase incomeUseCase;
  final ExpenseUseCase expenseUseCase;
  final SavingsUseCase savingsUseCase;
  final SavingsWithdrawalUseCase withdrawalUseCase;

  ReportBloc({
    required this.incomeUseCase,
    required this.expenseUseCase,
    required this.savingsUseCase,
    required this.withdrawalUseCase,
  }) : super(ReportInitial()) {
    on<LoadReport>(_onLoadReport);
    on<FilterReportByDate>(_onFilterReportByDate);
    on<AddSavingsWithdrawal>(_onAddSavingsWithdrawal);
  }

  Future<void> _onLoadReport(LoadReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final incomes = await incomeUseCase.getAllIncomes();
      final expenses = await expenseUseCase.getAllExpenses();
      final savings = await savingsUseCase.getAllSavings();
      final withdrawals = await withdrawalUseCase.getAllWithdrawals();

      emit(ReportLoaded(
        incomes: incomes,
        expenses: expenses,
        savings: savings,
        withdrawals: withdrawals,
        totalIncome: incomes.fold(0.0, (s, i) => s + i.amount),
        totalExpense: expenses.fold(0.0, (s, e) => s + e.amount),
        totalSavings: savings.fold(0.0, (s, sa) => s + sa.amount),
        totalWithdrawals: withdrawals.fold(0.0, (s, w) => s + w.amount),
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onFilterReportByDate(FilterReportByDate event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final incomes = await incomeUseCase.repository.getIncomesByDateRange(event.start, event.end);
      final expenses = await expenseUseCase.repository.getExpensesByDateRange(event.start, event.end);
      final savings = await savingsUseCase.repository.getSavingsByDateRange(event.start, event.end);
      final withdrawals = await withdrawalUseCase.repository.getWithdrawalsByDateRange(event.start, event.end);

      emit(ReportLoaded(
        incomes: incomes,
        expenses: expenses,
        savings: savings,
        withdrawals: withdrawals,
        totalIncome: incomes.fold(0.0, (s, i) => s + i.amount),
        totalExpense: expenses.fold(0.0, (s, e) => s + e.amount),
        totalSavings: savings.fold(0.0, (s, sa) => s + sa.amount),
        totalWithdrawals: withdrawals.fold(0.0, (s, w) => s + w.amount),
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onAddSavingsWithdrawal(AddSavingsWithdrawal event, Emitter<ReportState> emit) async {
    try {
      await withdrawalUseCase.addWithdrawal(event.withdrawal);
      add(LoadReport());
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
