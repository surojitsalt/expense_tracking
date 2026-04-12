import '../../../core/database/database_helper.dart';
import '../domain/income_model.dart';
import '../domain/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final DatabaseHelper db;
  static const String tableName = 'income_records';
  static const String categoryType = 'income';

  IncomeRepositoryImpl({required this.db});

  @override
  Future<int> addIncome(IncomeModel income) {
    return db.insert(tableName, income.toMap());
  }

  @override
  Future<int> deleteIncome(int id) {
    return db.delete(tableName, id);
  }

  @override
  Future<List<IncomeModel>> getAllIncomes() async {
    final maps = await db.queryAll(tableName);
    return maps.map((map) => IncomeModel.fromMap(map)).toList();
  }

  @override
  Future<IncomeModel?> getIncomeById(int id) async {
    final map = await db.queryById(tableName, id);
    if (map != null) {
      return IncomeModel.fromMap(map);
    }
    return null;
  }

  @override
  Future<List<IncomeModel>> getIncomesByDateRange(DateTime start, DateTime end) async {
    final maps = await db.queryByDateRange(
      tableName,
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => IncomeModel.fromMap(map)).toList();
  }

  @override
  Future<int> updateIncome(IncomeModel income) {
    return db.update(tableName, income.id!, income.toMap());
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
