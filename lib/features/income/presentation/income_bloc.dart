import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/income_model.dart';
import '../domain/income_usecase.dart';
import '../../savings/domain/savings_model.dart';
import '../../savings/domain/savings_usecase.dart';

// Events
abstract class IncomeEvent extends Equatable {
  const IncomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadIncomes extends IncomeEvent {}

class AddIncome extends IncomeEvent {
  final IncomeModel income;

  const AddIncome(this.income);

  @override
  List<Object?> get props => [income];
}

class DeleteIncome extends IncomeEvent {
  final int id;

  const DeleteIncome(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadCustomCategories extends IncomeEvent {}

class AddCustomCategory extends IncomeEvent {
  final String name;

  const AddCustomCategory(this.name);

  @override
  List<Object?> get props => [name];
}

// States
abstract class IncomeState extends Equatable {
  const IncomeState();

  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {}

class IncomeLoading extends IncomeState {}

class IncomeLoaded extends IncomeState {
  final List<IncomeModel> incomes;
  final List<String> customCategories;
  final double totalIncome;

  const IncomeLoaded(this.incomes, this.customCategories, this.totalIncome);

  @override
  List<Object?> get props => [incomes, customCategories, totalIncome];
}

class IncomeError extends IncomeState {
  final String message;

  const IncomeError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final IncomeUseCase incomeUseCase;
  final SavingsUseCase savingsUseCase;

  IncomeBloc({required this.incomeUseCase, required this.savingsUseCase}) : super(IncomeInitial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<AddIncome>(_onAddIncome);
    on<DeleteIncome>(_onDeleteIncome);
    on<LoadCustomCategories>(_onLoadCustomCategories);
    on<AddCustomCategory>(_onAddCustomCategory);
  }

  Future<void> _onLoadIncomes(LoadIncomes event, Emitter<IncomeState> emit) async {
    emit(IncomeLoading());
    try {
      final incomes = await incomeUseCase.getAllIncomes();
      final customCategories = await incomeUseCase.getCustomCategories();
      final totalIncome = incomes.fold(0.0, (sum, item) => sum + item.amount);
      emit(IncomeLoaded(incomes, customCategories, totalIncome));
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomeState> emit) async {
    try {
      await incomeUseCase.addIncome(event.income);
      if (event.income.category == 'Savings') {
        final withdrawal = SavingsModel(
          amount: -event.income.amount,
          category: 'Withdrawn',
          description: event.income.description,
          date: event.income.date,
          createdAt: DateTime.now(),
        );
        await savingsUseCase.addSaving(withdrawal);
      }
      add(LoadIncomes());
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onDeleteIncome(DeleteIncome event, Emitter<IncomeState> emit) async {
    try {
      await incomeUseCase.deleteIncome(event.id);
      add(LoadIncomes());
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }

  Future<void> _onLoadCustomCategories(LoadCustomCategories event, Emitter<IncomeState> emit) async {
    if (state is IncomeLoaded) {
      final currentState = state as IncomeLoaded;
      try {
        final customCategories = await incomeUseCase.getCustomCategories();
        emit(IncomeLoaded(currentState.incomes, customCategories, currentState.totalIncome));
      } catch (e) {
        emit(IncomeError(e.toString()));
      }
    }
  }

  Future<void> _onAddCustomCategory(AddCustomCategory event, Emitter<IncomeState> emit) async {
    try {
      await incomeUseCase.addCustomCategory(event.name);
      add(LoadIncomes()); // Reloads incomes and categories
    } catch (e) {
      emit(IncomeError(e.toString()));
    }
  }
}
