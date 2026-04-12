import 'expense_model.dart';
import 'expense_repository.dart';

class ExpenseUseCase {
  final ExpenseRepository repository;

  ExpenseUseCase(this.repository);

  Future<List<ExpenseModel>> getAllExpenses() => repository.getAllExpenses();
  
  Future<int> addExpense(ExpenseModel expense) {
    if (expense.amount <= 0) {
      throw Exception("Amount must be greater than zero");
    }
    return repository.addExpense(expense);
  }

  Future<int> deleteExpense(int id) => repository.deleteExpense(id);
  
  Future<List<String>> getCustomCategories() => repository.getCustomCategories();
  
  Future<void> addCustomCategory(String name) => repository.addCustomCategory(name);
}
