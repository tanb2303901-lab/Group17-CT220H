import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  // Cache toàn bộ giao dịch
  List<Transaction> _allTransactions = [];
  DateTime? _selectedMonth;

  FinanceBloc({
    required this._getTransactions,
    required this._addTransaction,
    required this._updateTransaction,
    required this._deleteTransaction,
  }) : super(FinanceInitial()) {
    on<FetchTransactionsEvent>(_onFetchTransactions);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<FilterByMonthEvent>(_onFilterByMonth);
  }

  Future<void> _onFetchTransactions(
    FetchTransactionsEvent event,
    Emitter<FinanceState> emit,
  ) async {
    emit(FinanceLoading());
    try {
      final transactions = await _getTransactions(NoParams());
      _allTransactions = transactions.cast<Transaction>();
      emit(_buildLoadedState());
    } catch (e) {
      emit(FinanceError('Lỗi tải dữ liệu chi tiêu: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransaction(
    AddTransactionEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await _addTransaction(event.transaction);
      add(FetchTransactionsEvent());
    } catch (e) {
      emit(FinanceError('Không thể thêm giao dịch: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await _updateTransaction(event.transaction);
      add(FetchTransactionsEvent());
    } catch (e) {
      emit(FinanceError('Không thể cập nhật giao dịch: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<FinanceState> emit,
  ) async {
    try {
      await _deleteTransaction(event.id);
      final transactions = await _getTransactions(NoParams());
      _allTransactions = transactions.cast<Transaction>();
      emit(_buildLoadedState());
    } catch (e) {
      emit(FinanceError('Lỗi xóa giao dịch: ${e.toString()}'));
    }
  }

  void _onFilterByMonth(FilterByMonthEvent event, Emitter<FinanceState> emit) {
    _selectedMonth = event.month;
    emit(_buildLoadedState());
  }

  FinanceLoaded _buildLoadedState() {
    // Lọc theo tháng nếu có chọn
    final filtered = _selectedMonth == null
        ? _allTransactions
        : _allTransactions.where((t) {
            return t.date.year == _selectedMonth!.year &&
                t.date.month == _selectedMonth!.month;
          }).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    Map<String, double> categoryExpenses = {};

    for (final transaction in filtered) {
      if (transaction.isIncome) {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
        categoryExpenses[transaction.category] =
            (categoryExpenses[transaction.category] ?? 0.0) +
            transaction.amount;
      }
    }

    return FinanceLoaded(
      transactions: filtered,
      allTransactions: _allTransactions,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
      categoryExpenses: categoryExpenses,
      selectedMonth: _selectedMonth,
    );
  }
}
