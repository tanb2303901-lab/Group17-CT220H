import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String type; // 'income' hoặc 'expense'
  final String category;
  final DateTime date;
  final int importanceScore; // 1 đến 5 (chỉ dùng cho expense)

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.importanceScore = 3,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  @override
  List<Object?> get props => [id, title, amount, type, category, date, importanceScore];
}
