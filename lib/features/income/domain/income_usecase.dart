import 'income_model.dart';
import 'income_repository.dart';

class IncomeUseCase {
  final IncomeRepository repository;

  IncomeUseCase(this.repository);

  Future<List<IncomeModel>> getAllIncomes() => repository.getAllIncomes();
  
  Future<int> addIncome(IncomeModel income) {
    if (income.amount <= 0) {
      throw Exception("Amount must be greater than zero");
    }
    return repository.addIncome(income);
  }

  Future<int> deleteIncome(int id) => repository.deleteIncome(id);
  
  Future<List<String>> getCustomCategories() => repository.getCustomCategories();
  
  Future<void> addCustomCategory(String name) => repository.addCustomCategory(name);
}
