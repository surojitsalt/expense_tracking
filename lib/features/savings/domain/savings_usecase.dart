import 'savings_model.dart';
import 'savings_repository.dart';

class SavingsUseCase {
  final SavingsRepository repository;

  SavingsUseCase(this.repository);

  Future<List<SavingsModel>> getAllSavings() => repository.getAllSavings();
  
  Future<int> addSaving(SavingsModel saving) {
    if (saving.amount == 0) {
      throw Exception("Amount cannot be zero");
    }
    if (saving.amount < 0 && saving.category != 'Withdrawn') {
      throw Exception("Amount must be greater than zero");
    }
    return repository.addSaving(saving);
  }

  Future<int> updateSaving(SavingsModel saving) {
    if (saving.id == null) {
      throw Exception("Cannot update a saving without an id");
    }
    if (saving.amount == 0) {
      throw Exception("Amount cannot be zero");
    }
    if (saving.amount < 0 && saving.category != 'Withdrawn') {
      throw Exception("Amount must be greater than zero");
    }
    return repository.updateSaving(saving);
  }

  Future<int> deleteSaving(int id) => repository.deleteSaving(id);
  
  Future<List<String>> getCustomCategories() => repository.getCustomCategories();
  
  Future<void> addCustomCategory(String name) => repository.addCustomCategory(name);
}
