import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/savings_model.dart';
import '../domain/savings_usecase.dart';

// Events
abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSavings extends SavingsEvent {}

class AddSaving extends SavingsEvent {
  final SavingsModel saving;

  const AddSaving(this.saving);

  @override
  List<Object?> get props => [saving];
}

class DeleteSaving extends SavingsEvent {
  final int id;

  const DeleteSaving(this.id);

  @override
  List<Object?> get props => [id];
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

  SavingsBloc({required this.savingsUseCase}) : super(SavingsInitial()) {
    on<LoadSavings>(_onLoadSavings);
    on<AddSaving>(_onAddSaving);
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

  Future<void> _onAddSaving(AddSaving event, Emitter<SavingsState> emit) async {
    try {
      await savingsUseCase.addSaving(event.saving);
      add(LoadSavings());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onDeleteSaving(DeleteSaving event, Emitter<SavingsState> emit) async {
    try {
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
