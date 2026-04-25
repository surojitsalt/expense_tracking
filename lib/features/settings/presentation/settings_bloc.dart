import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/currency_model.dart';
import '../data/settings_service.dart';

// Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class ChangeCurrency extends SettingsEvent {
  final String code;
  const ChangeCurrency(this.code);
  @override
  List<Object?> get props => [code];
}

// State
class SettingsState extends Equatable {
  final CurrencyModel currency;

  const SettingsState({required this.currency});

  String get currencySymbol => currency.symbol;

  SettingsState copyWith({CurrencyModel? currency}) =>
      SettingsState(currency: currency ?? this.currency);

  @override
  List<Object?> get props => [currency.code];
}

// BLoC
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService settingsService;

  SettingsBloc({required this.settingsService})
      : super(SettingsState(currency: kSupportedCurrencies[0])) {
    on<LoadSettings>(_onLoad);
    on<ChangeCurrency>(_onChange);
  }

  Future<void> _onLoad(LoadSettings event, Emitter<SettingsState> emit) async {
    final currency = await settingsService.loadCurrency();
    emit(state.copyWith(currency: currency));
  }

  Future<void> _onChange(
      ChangeCurrency event, Emitter<SettingsState> emit) async {
    await settingsService.saveCurrency(event.code);
    final currency = kSupportedCurrencies.firstWhere(
      (c) => c.code == event.code,
      orElse: () => kSupportedCurrencies.first,
    );
    emit(state.copyWith(currency: currency));
  }
}
