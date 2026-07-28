import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class AddTransaction implements UseCase<void, Transaction> {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  @override
  Future<void> call(Transaction transaction) async {
    return await repository.addTransaction(transaction);
  }
}
