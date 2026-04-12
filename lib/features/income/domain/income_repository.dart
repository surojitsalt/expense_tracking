import 'income_model.dart';

abstract class IncomeRepository {
  Future<List<IncomeModel>> getAllIncomes();
  Future<IncomeModel?> getIncomeById(int id);
  Future<int> addIncome(IncomeModel income);
  Future<int> updateIncome(IncomeModel income);
  Future<int> deleteIncome(int id);
  Future<List<IncomeModel>> getIncomesByDateRange(DateTime start, DateTime end);
  Future<List<String>> getCustomCategories();
  Future<void> addCustomCategory(String name);
}
