import 'savings_withdrawal_model.dart';
import 'savings_withdrawal_repository.dart';

class SavingsWithdrawalUseCase {
  final SavingsWithdrawalRepository repository;

  SavingsWithdrawalUseCase(this.repository);

  Future<List<SavingsWithdrawalModel>> getAllWithdrawals() => repository.getAllWithdrawals();

  Future<int> addWithdrawal(SavingsWithdrawalModel withdrawal) {
    if (withdrawal.amount <= 0) {
      throw Exception('Withdrawal amount must be greater than zero');
    }
    return repository.addWithdrawal(withdrawal);
  }

  Future<int> deleteWithdrawal(int id) => repository.deleteWithdrawal(id);
}
