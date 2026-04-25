class CurrencyModel {
  final String code;
  final String symbol;
  final String name;

  const CurrencyModel({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

const List<CurrencyModel> kSupportedCurrencies = [
  CurrencyModel(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
  CurrencyModel(code: 'USD', symbol: '\$', name: 'US Dollar'),
  CurrencyModel(code: 'EUR', symbol: '€', name: 'Euro'),
  CurrencyModel(code: 'GBP', symbol: '£', name: 'British Pound'),
  CurrencyModel(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
  CurrencyModel(code: 'CAD', symbol: '\$', name: 'Canadian Dollar'),
  CurrencyModel(code: 'AUD', symbol: '\$', name: 'Australian Dollar'),
  CurrencyModel(code: 'SGD', symbol: '\$', name: 'Singapore Dollar'),
  CurrencyModel(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc'),
  CurrencyModel(code: 'AED', symbol: 'د.إ', name: 'UAE Dirham'),
];
