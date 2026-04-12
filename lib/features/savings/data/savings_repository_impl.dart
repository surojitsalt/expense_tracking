import '../../../../core/database/database_helper.dart';
import '../domain/savings_model.dart';
import '../domain/savings_repository.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final DatabaseHelper db;
  static const String tableName = 'savings_records';
  static const String categoryType = 'savings';

  SavingsRepositoryImpl({required this.db});

  @override
  Future<int> addSaving(SavingsModel saving) {
    return db.insert(tableName, saving.toMap());
  }

  @override
  Future<int> deleteSaving(int id) {
    return db.delete(tableName, id);
  }

  @override
  Future<List<SavingsModel>> getAllSavings() async {
    final maps = await db.queryAll(tableName);
    return maps.map((map) => SavingsModel.fromMap(map)).toList();
  }

  @override
  Future<SavingsModel?> getSavingById(int id) async {
    final map = await db.queryById(tableName, id);
    if (map != null) {
      return SavingsModel.fromMap(map);
    }
    return null;
  }

  @override
  Future<List<SavingsModel>> getSavingsByDateRange(DateTime start, DateTime end) async {
    final maps = await db.queryByDateRange(
      tableName,
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => SavingsModel.fromMap(map)).toList();
  }

  @override
  Future<int> updateSaving(SavingsModel saving) {
    return db.update(tableName, saving.id!, saving.toMap());
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
