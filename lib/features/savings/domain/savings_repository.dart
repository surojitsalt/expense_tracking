import 'savings_model.dart';

abstract class SavingsRepository {
  Future<List<SavingsModel>> getAllSavings();
  Future<SavingsModel?> getSavingById(int id);
  Future<int> addSaving(SavingsModel saving);
  Future<int> updateSaving(SavingsModel saving);
  Future<int> deleteSaving(int id);
  Future<List<SavingsModel>> getSavingsByDateRange(DateTime start, DateTime end);
  Future<List<String>> getCustomCategories();
  Future<void> addCustomCategory(String name);
}
