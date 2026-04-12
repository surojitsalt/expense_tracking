import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/expense_model.dart';
import '../domain/expense_usecase.dart';

// Events
abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class LoadExpenses extends ExpenseEvent {}

class AddExpense extends ExpenseEvent {
  final ExpenseModel expense;

  const AddExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final int id;

  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCustomCategories extends ExpenseEvent {}

class AddCustomCategory extends ExpenseEvent {
  final String name;

  const AddCustomCategory(this.name);

  @override
  List<Object?> get props => [name];
}

// States
abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpenseLoaded extends ExpenseState {
  final List<ExpenseModel> expenses;
  final List<String> customCategories;
  final double totalExpense;

  const ExpenseLoaded(this.expenses, this.customCategories, this.totalExpense);

  @override
  List<Object?> get props => [expenses, customCategories, totalExpense];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseUseCase expenseUseCase;

  ExpenseBloc({required this.expenseUseCase}) : super(ExpenseInitial()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<LoadCustomCategories>(_onLoadCustomCategories);
    on<AddCustomCategory>(_onAddCustomCategory);
  }

  Future<void> _onLoadExpenses(LoadExpenses event, Emitter<ExpenseState> emit) async {
    emit(ExpenseLoading());
    try {
      final expenses = await expenseUseCase.getAllExpenses();
      final customCategories = await expenseUseCase.getCustomCategories();
      final totalExpense = expenses.fold(0.0, (sum, item) => sum + item.amount);
      emit(ExpenseLoaded(expenses, customCategories, totalExpense));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onAddExpense(AddExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseUseCase.addExpense(event.expense);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onDeleteExpense(DeleteExpense event, Emitter<ExpenseState> emit) async {
    try {
      await expenseUseCase.deleteExpense(event.id);
      add(LoadExpenses());
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> _onLoadCustomCategories(LoadCustomCategories event, Emitter<ExpenseState> emit) async {
    if (state is ExpenseLoaded) {
      final currentState = state as ExpenseLoaded;
      try {
        final customCategories = await expenseUseCase.getCustomCategories();
        emit(ExpenseLoaded(currentState.expenses, customCategories, currentState.totalExpense));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    }
  }

  Future<void> _onAddCustomCategory(AddCustomCategory event, Emitter<ExpenseState> emit) async {
    try {
      await expenseUseCase.addCustomCategory(event.name);
      add(LoadExpenses()); 
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}
