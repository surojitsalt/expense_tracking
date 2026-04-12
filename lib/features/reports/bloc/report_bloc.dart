import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../income/domain/income_model.dart';
import '../../income/domain/income_usecase.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/domain/expense_usecase.dart';
import '../../savings/domain/savings_model.dart';
import '../../savings/domain/savings_usecase.dart';

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
  final double totalIncome;
  final double totalExpense;
  final double totalSavings;

  const ReportLoaded({
    required this.incomes,
    required this.expenses,
    required this.savings,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalSavings,
  });

  @override
  List<Object?> get props => [incomes, expenses, savings, totalIncome, totalExpense, totalSavings];
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

  ReportBloc({
    required this.incomeUseCase,
    required this.expenseUseCase,
    required this.savingsUseCase,
  }) : super(ReportInitial()) {
    on<LoadReport>(_onLoadReport);
    on<FilterReportByDate>(_onFilterReportByDate);
  }

  Future<void> _onLoadReport(LoadReport event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    try {
      final incomes = await incomeUseCase.getAllIncomes();
      final expenses = await expenseUseCase.getAllExpenses();
      final savings = await savingsUseCase.getAllSavings();

      final totalIncome = incomes.fold(0.0, (s, i) => s + i.amount);
      final totalExpense = expenses.fold(0.0, (s, e) => s + e.amount);
      final totalSavings = savings.fold(0.0, (s, sa) => s + sa.amount);

      emit(ReportLoaded(
        incomes: incomes,
        expenses: expenses,
        savings: savings,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        totalSavings: totalSavings,
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

      final totalIncome = incomes.fold(0.0, (s, i) => s + i.amount);
      final totalExpense = expenses.fold(0.0, (s, e) => s + e.amount);
      final totalSavings = savings.fold(0.0, (s, sa) => s + sa.amount);

      emit(ReportLoaded(
        incomes: incomes,
        expenses: expenses,
        savings: savings,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        totalSavings: totalSavings,
      ));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
