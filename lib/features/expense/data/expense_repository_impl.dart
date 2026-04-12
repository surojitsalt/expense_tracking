import '../../../../core/database/database_helper.dart';
import '../domain/expense_model.dart';
import '../domain/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper db;
  static const String tableName = 'expense_records';
  static const String categoryType = 'expense';

  ExpenseRepositoryImpl({required this.db});

  @override
  Future<int> addExpense(ExpenseModel expense) {
    return db.insert(tableName, expense.toMap());
  }

  @override
  Future<int> deleteExpense(int id) {
    return db.delete(tableName, id);
  }

  @override
  Future<List<ExpenseModel>> getAllExpenses() async {
    final maps = await db.queryAll(tableName);
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  @override
  Future<ExpenseModel?> getExpenseById(int id) async {
    final map = await db.queryById(tableName, id);
    if (map != null) {
      return ExpenseModel.fromMap(map);
    }
    return null;
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange(DateTime start, DateTime end) async {
    final maps = await db.queryByDateRange(
      tableName,
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => ExpenseModel.fromMap(map)).toList();
  }

  @override
  Future<int> updateExpense(ExpenseModel expense) {
    return db.update(tableName, expense.id!, expense.toMap());
  }

  @override
  Future<List<String>> getCustomCategories() async {
    final maps = await db.getCustomCategories(categoryType);
    return maps.map((map) => map['name'] as String).toList();
  }

  @override
  Future<void> addCustomCategory(String name) async {
    await db.addCustomCategory(name, categoryType);
  }
}
