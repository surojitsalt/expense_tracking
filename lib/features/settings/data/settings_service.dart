import 'package:shared_preferences/shared_preferences.dart';
import '../domain/currency_model.dart';

class SettingsService {
  static const _currencyCodeKey = 'currency_code';

  Future<CurrencyModel> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_currencyCodeKey) ?? 'INR';
    return kSupportedCurrencies.firstWhere(
      (c) => c.code == code,
      orElse: () => kSupportedCurrencies.first,
    );
  }

  Future<void> saveCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyCodeKey, code);
  }
}
