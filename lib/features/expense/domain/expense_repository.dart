import 'expense_model.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getAllExpenses();
  Future<ExpenseModel?> getExpenseById(int id);
  Future<int> addExpense(ExpenseModel expense);
  Future<int> updateExpense(ExpenseModel expense);
  Future<int> deleteExpense(int id);
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end);
  Future<List<String>> getCustomCategories();
  Future<void> addCustomCategory(String name);
}
