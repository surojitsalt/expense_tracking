import '../../../../core/database/database_helper.dart';
import '../domain/savings_withdrawal_model.dart';
import '../domain/savings_withdrawal_repository.dart';

class SavingsWithdrawalRepositoryImpl implements SavingsWithdrawalRepository {
  final DatabaseHelper db;
  static const String tableName = 'savings_withdrawals';

  SavingsWithdrawalRepositoryImpl({required this.db});

  @override
  Future<int> addWithdrawal(SavingsWithdrawalModel withdrawal) {
    return db.insert(tableName, withdrawal.toMap());
  }

  @override
  Future<int> deleteWithdrawal(int id) {
    return db.delete(tableName, id);
  }

  @override
  Future<List<SavingsWithdrawalModel>> getAllWithdrawals() async {
    final maps = await db.queryAll(tableName);
    return maps.map((map) => SavingsWithdrawalModel.fromMap(map)).toList();
  }

  @override
  Future<List<SavingsWithdrawalModel>> getWithdrawalsByDateRange(DateTime start, DateTime end) async {
    final maps = await db.queryByDateRange(
      tableName,
      start.toIso8601String(),
      end.toIso8601String(),
    );
    return maps.map((map) => SavingsWithdrawalModel.fromMap(map)).toList();
  }
}
