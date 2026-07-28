import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<Transaction>, NoParams> {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  @override
  Future<List<Transaction>> call(NoParams params) async {
    return await repository.getTransactions();
  }
}
