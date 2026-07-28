import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<void, String> {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  @override
  Future<void> call(String id) async {
    return await repository.deleteTransaction(id);
  }
}
