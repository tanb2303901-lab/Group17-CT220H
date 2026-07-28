import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

class FetchTransactionsEvent extends FinanceEvent {}

class AddTransactionEvent extends FinanceEvent {
  final Transaction transaction;

  const AddTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends FinanceEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event lọc giao dịch theo tháng/năm cụ thể
class FilterByMonthEvent extends FinanceEvent {
  /// null = hiển thị tất cả
  final DateTime? month;

  const FilterByMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}
