import 'savings_withdrawal_model.dart';

abstract class SavingsWithdrawalRepository {
  Future<List<SavingsWithdrawalModel>> getAllWithdrawals();
  Future<int> addWithdrawal(SavingsWithdrawalModel withdrawal);
  Future<int> deleteWithdrawal(int id);
  Future<List<SavingsWithdrawalModel>> getWithdrawalsByDateRange(DateTime start, DateTime end);
}
