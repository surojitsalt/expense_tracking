import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/savings_model.dart';
import '../domain/savings_usecase.dart';
import '../../expense/domain/expense_model.dart';
import '../../expense/domain/expense_usecase.dart';

// Events
abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavings extends SavingsEvent {}

class AddSaving extends SavingsEvent {
  final SavingsModel saving;
  // When true, also create a matching expense (category 'Savings') so the
  // saving is deducted from income in reports.
  final bool linkToIncome;

  const AddSaving(this.saving, {this.linkToIncome = false});

  @override
  List<Object?> get props => [saving, linkToIncome];
}

class UpdateSaving extends SavingsEvent {
  final SavingsModel saving;
  final bool linkToIncome;

  const UpdateSaving(this.saving, {this.linkToIncome = false});

  @override
  List<Object?> get props => [saving, linkToIncome];
}

class DeleteSaving extends SavingsEvent {
  final int id;
  // Id of the linked expense to remove alongside the saving, if any.
  final int? linkedExpenseId;

  const DeleteSaving(this.id, {this.linkedExpenseId});

  @override
  List<Object?> get props => [id, linkedExpenseId];
}

class LoadCustomCategories extends SavingsEvent {}

class AddCustomCategory extends SavingsEvent {
  final String name;

  const AddCustomCategory(this.name);

  @override
  List<Object?> get props => [name];
}

// States
abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsLoaded extends SavingsState {
  final List<SavingsModel> savings;
  final List<String> customCategories;
  final double totalSavings;

  const SavingsLoaded(this.savings, this.customCategories, this.totalSavings);

  @override
  List<Object?> get props => [savings, customCategories, totalSavings];
}

class SavingsError extends SavingsState {
  final String message;

  const SavingsError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final SavingsUseCase savingsUseCase;
  final ExpenseUseCase expenseUseCase;

  // Category used for the expense row mirroring an income-linked saving.
  static const String linkedExpenseCategory = 'Savings';

  SavingsBloc({required this.savingsUseCase, required this.expenseUseCase})
      : super(SavingsInitial()) {
    on<LoadSavings>(_onLoadSavings);
    on<AddSaving>(_onAddSaving);
    on<UpdateSaving>(_onUpdateSaving);
    on<DeleteSaving>(_onDeleteSaving);
    on<LoadCustomCategories>(_onLoadCustomCategories);
    on<AddCustomCategory>(_onAddCustomCategory);
  }

  Future<void> _onLoadSavings(LoadSavings event, Emitter<SavingsState> emit) async {
    emit(SavingsLoading());
    try {
      final savings = await savingsUseCase.getAllSavings();
      final customCategories = await savingsUseCase.getCustomCategories();
      final totalSavings = savings.fold(0.0, (sum, item) => sum + item.amount);
      emit(SavingsLoaded(savings, customCategories, totalSavings));
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  // Builds the expense that mirrors an income-linked saving.
  ExpenseModel _linkedExpenseFor(SavingsModel saving, {int? id}) {
    return ExpenseModel(
      id: id,
      amount: saving.amount,
      category: linkedExpenseCategory,
      description: saving.description,
      date: saving.date,
      createdAt: saving.createdAt,
    );
  }

  Future<void> _onAddSaving(AddSaving event, Emitter<SavingsState> emit) async {
    try {
      var saving = event.saving;
      if (event.linkToIncome) {
        final expenseId = await expenseUseCase.addExpense(_linkedExpenseFor(saving));
        saving = saving.copyWith(linkedExpenseId: expenseId);
      }
      await savingsUseCase.addSaving(saving);
      add(LoadSavings());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSaving(UpdateSaving event, Emitter<SavingsState> emit) async {
    try {
      final existingLinkedId = event.saving.linkedExpenseId;
      int? linkedId = existingLinkedId;
      if (event.linkToIncome) {
        if (existingLinkedId != null) {
          await expenseUseCase
              .updateExpense(_linkedExpenseFor(event.saving, id: existingLinkedId));
        } else {
          linkedId = await expenseUseCase.addExpense(_linkedExpenseFor(event.saving));
        }
      } else if (existingLinkedId != null) {
        // Link was turned off: drop the mirrored expense.
        await expenseUseCase.deleteExpense(existingLinkedId);
        linkedId = null;
      }
      // Rebuild explicitly so linkedExpenseId can be cleared to null.
      await savingsUseCase.updateSaving(
        SavingsModel(
          id: event.saving.id,
          amount: event.saving.amount,
          category: event.saving.category,
          description: event.saving.description,
          date: event.saving.date,
          createdAt: event.saving.createdAt,
          linkedExpenseId: linkedId,
        ),
      );
      add(LoadSavings());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onDeleteSaving(DeleteSaving event, Emitter<SavingsState> emit) async {
    try {
      if (event.linkedExpenseId != null) {
        await expenseUseCase.deleteExpense(event.linkedExpenseId!);
      }
      await savingsUseCase.deleteSaving(event.id);
      add(LoadSavings());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onLoadCustomCategories(LoadCustomCategories event, Emitter<SavingsState> emit) async {
    if (state is SavingsLoaded) {
      final currentState = state as SavingsLoaded;
      try {
        final customCategories = await savingsUseCase.getCustomCategories();
        emit(SavingsLoaded(currentState.savings, customCategories, currentState.totalSavings));
      } catch (e) {
        emit(SavingsError(e.toString()));
      }
    }
  }

  Future<void> _onAddCustomCategory(AddCustomCategory event, Emitter<SavingsState> emit) async {
    try {
      await savingsUseCase.addCustomCategory(event.name);
      add(LoadSavings()); 
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }
}
