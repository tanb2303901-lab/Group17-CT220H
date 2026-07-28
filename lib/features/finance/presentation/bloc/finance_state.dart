import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();

  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {
  final List<Transaction> transactions; // danh sách đã lọc (theo tháng)
  final List<Transaction> allTransactions; // toàn bộ giao dịch
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> categoryExpenses;
  final DateTime? selectedMonth; // null = tất cả

  const FinanceLoaded({
    required this.transactions,
    required this.allTransactions,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.categoryExpenses,
    this.selectedMonth,
  });

  @override
  List<Object?> get props => [
    transactions,
    allTransactions,
    totalIncome,
    totalExpense,
    balance,
    categoryExpenses,
    selectedMonth,
  ];
}

class FinanceError extends FinanceState {
  final String message;

  const FinanceError(this.message);

  @override
  List<Object?> get props => [message];
}
